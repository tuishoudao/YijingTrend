--Zipf's Law
-- Common blocks ---
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight

-- Functions ---
local index = 1

local function isAlpha(c )
	if (c == nil ) then return false end
--	print ( "c=",c)
	if ((c >= string.byte('a') and  c <= string.byte('z') ) or (c >= string.byte('A')  and  c <= string.byte('Z') )) then
--		print ( "c=",c)
		return true
	else return false end
end

----- getWord ------

local function getWord(lineString )
	local wordString = ""
	local i= index

	if (lineString == nil ) then return nil end
--	print ("getWord:", i , "line:",#lineString,"c:",lineString:byte(i))
	while (isAlpha(lineString:byte(i)) == false ) do
		if (index >= #lineString ) then -- found end char
			index = 1
			return nil
		end
		i=i+1
		index = index + 1

	end

	repeat
		wordString = wordString .. lineString:sub(i,i)
		i=i+1
		index = index + 1
	until (isAlpha(lineString:byte(i)) == false )
--	print (wordString)
	if (wordString == "") then return nil
	else return wordString
	end
end
--------- UTF8 ---------

function filter_spec_chars(s)
    local ss = {}
    for k = 1, #s do
        local c = string.byte(s,k)
        if not c then break end
        if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
            table.insert(ss, string.char(c))
        elseif c>=228 and c<=233 then
            local c1 = string.byte(s,k+1)
            local c2 = string.byte(s,k+2)
            if c1 and c2 then
                local a1,a2,a3,a4 = 128,191,128,191
                if c == 228 then a1 = 184
                elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                end
                if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                    k = k + 2
                    table.insert(ss, string.char(c,c1,c2))
                end
            end
        end
    end
    return table.concat(ss)
end

-- main --

avKey="H1J2WIZHF1BIO4BR"
StockSymbol="QCOM"


display.setStatusBar( display.HiddenStatusBar )

local json = require("json")

-- Access Google over SSL:
local url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=" ..
	StockSymbol .. "&apikey=" .. avKey

local myTitle = display.newText("AsyncHTTP", display.contentCenterX, 15, native.systemFont, 20)
local myText = display.newText("(Waiting for response)", display.contentCenterX, 45, native.systemFont, 14)

local myInfoBackground = display.newRect( display.contentCenterX, display.contentCenterY + 30, display.contentWidth - 20, display.contentHeight - 80 )
local myInfo = display.newText("", myInfoBackground.x, myInfoBackground.y, myInfoBackground.width - 10, myInfoBackground.height - 10, "Courier New", 8)
myInfo:setFillColor( 0, 0, 0 )

local function networkListener( event )
	if ( event.isError ) then
		myText.text = "Network error!"
		myInfo.text = "networkRequest event: " .. json.prettify(event)

	else
		local rawResponse = event.response

		myText.text = "Server responded with HTTP status " .. event.status
		event.response = "<data from retrieved URL is available here>"
		myInfo.text = "networkRequest event: " .. json.prettify(event) .. "\n\n(see console for complete network event)"

		print ( "networkRequest event: " .. json.prettify(event) )
		print ( "RESPONSE: " .. tostring(rawResponse) )
	end
end

myInfo.text = "Requesting " .. url .. " ..."

network.request( url, "GET", networkListener )

-- Update the app layout on resize event.
local function onResize( event )
	-- Update title.
	myTitle.x = display.contentCenterX
	myText.x = display.contentCenterX

	-- Update response field background.
	myInfoBackground.x = display.contentCenterX
	myInfoBackground.y = display.contentCenterY + 30
	myInfoBackground.width = display.contentWidth - 20
	myInfoBackground.height = display.contentHeight - 80

	-- Update response field. This does not update cleanly, and needs to be recreated.
	local myInfoText = myInfo.text
	myInfo:removeSelf()
	myInfo = display.newText(myInfoText, myInfoBackground.x, myInfoBackground.y, myInfoBackground.width - 10, myInfoBackground.height - 10, "Courier New", 8)
	myInfo:setFillColor( 0, 0, 0 )
end
Runtime:addEventListener( "resize", onResize )

-- On tvOS, we want to make sure we stay awake.
-- We also want to ensure that the menu button exits the app.
if system.getInfo( "platformName" ) == "tvOS" then
	system.activate( "controllerUserInteraction" )
	system.setIdleTimer( false )
end
