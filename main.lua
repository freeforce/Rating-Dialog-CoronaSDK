--[[
 Add a ratings dialog in your apps using this library
 © OZ Apps, 2011
 email   : Info.OzApps@gmail.com
 twitter : @ozapps
 website : http://www.oz-apps.com
 Author  : Jayant C Varma
 License : released under the DWTFYWWTC license (this stands for Do What The F* You Want With That Code
--]]

--[[

	How to use this class : 
	

]]--

local DEBUG = false
local APP_NAME = "The App"
local APP_ID = 1234567
local DAYS_UNTIL_PROMPT = 30
local USES_UNTIL_PROMPT = 20
local TIME_AFTER_REMINDER = 1
local THE_VERSION = 1.3

local prop = require ("property")
local propertyBag

--Check for a network connection, returns true or false depending on if a internet connection is present
local testNetworkConnection = function ()
    local netConn = require('socket').connect('www.oz-apps.com', 80)
    if netConn == nil then
        return false
    end
    netConn:close()
    return true
end

local onShowRatingClick = function ( event )
	local intSelected = event.index
	
	if intSelected == 3 then -- Rate Later
		propertyBag:setProperty ( "ReminderRequestDate", os.time() + (60 * 60 * 24 * TIME_AFTER_REMINDER) )
		propertyBag:SaveToFile()
		
	elseif intSelected == 2 then -- Rate App
		local DEVICE = system.getInfo ( "environment" )
		ReviewURL = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" .. APP_ID
		propertyBag:setProperty ( "RatedCurrentVersion", "YES" )
		propertyBag:SaveToFile()
		if DEVICE == "simulator" then
			print ( "Cannot spawn this URL in the simulator" )
		else
			system.openURL ( ReviewURL )
		end
		
	elseif intSelected == 1 then -- No Thanks
		propertyBag:setProperty ( "DeclinedToRate", "YES" )
		propertyBag:SaveToFile()
		
	end
	
	if DEBUG then propertyBag:printTable() end 
end

local showRatingAlert = function ()
	native.showAlert(
		"If you enjoy using " .. APP_NAME .. ", would you mind taking a moment to rate it? It wouldn't take more than a minute. Thanks for your support!",
		"Rate " .. APP_NAME , 
		{ 
			"No Thanks",
			"Rate " .. APP_NAME,
			"Remind me later"
		},
		onShowRatingClick
		);
end

local incrementUseCount = function ()
--Get the version Number and check if the ratings are for this version

	local version = tonumber(propertyBag:getProperty( "CurrentVersion" ))
	
	print (version)
	print (THE_VERSION)
	
	
	if THE_VERSION <= tonumber(version) then
		local timeInterval = propertyBag:getProperty ( "FirstUseDate" )
		if timeInterval == 0 then
			timeInterval = os.time()
			propertyBag:setProperty ( "FirstUseDate", timeInterval )
		propertyBag:SaveToFile()
		end
		
		local useCount = propertyBag:getProperty ( "UseCount" )
		propertyBag:setProperty ( "UseCount", useCount + 1 )			
		propertyBag:SaveToFile()
	else --reset all settings
		propertyBag:setProperty ( "CurrentVersion", THE_VERSION )	
		propertyBag:setProperty ( "FirstUseDate", os.time() )	
		propertyBag:setProperty ( "UseCount", 1 )	
		propertyBag:setProperty ( "SignificantUseCount", 0 )	
		propertyBag:setProperty ( "RatedCurrentVersion", "NO" )	
		propertyBag:setProperty ( "DeclinedToRate", "NO" )	
		propertyBag:setProperty ( "ReminderRequestDate", os.time() )	
		propertyBag:SaveToFile()
	end
end

local ratingConditionsHaveBeenMet = function ()

	if DEBUG then return true end	
	
	if not testNetworkConnection() then return false end

	if propertyBag:getProperty ( "DeclinedToRate" ) == "YES" then return false end

	if propertyBag:getProperty ( "RatedCurrentVersion" ) == "YES" then return false end

--[[	
	--TODO: Still need to fix the time routines

	local dateFirstLaunch = os.time() - tonumber(propertyBag:getProperty ( "FirstUseDate" ))
	local timeUntilRate = 60 * 60 * 24 * DAYS_UNTIL_PROMPT
	if dateFirstLaunch < timeUntilRate then return false end

	local reminderRequestDate = tonumber(propertyBag:getProperty ( "ReminderRequestDate" ) - os.time())
	local timeUntilReminder =  60 * 60 * 24 * TIME_AFTER_REMINDER
	if reminderRequestDate < timeUntilReminder then return false end	
--]]

	local useCount = tonumber(propertyBag:getProperty ( "UseCount" ))
	if useCount < USES_UNTIL_PROMPT then return false end
	
	local version = propertyBag:getProperty ( "CurrentVersion" )
	if tonumber(version) > THE_VERSION then return false end
	
	return true
end

local main = function ()
	propertyBag = prop:init()

	propertyBag:setProperty ( "CurrentVersion", THE_VERSION )
	propertyBag:setProperty ( "FirstUseDate", os.time() )
	propertyBag:setProperty ( "UseCount", 0 )
	propertyBag:setProperty ( "SignificantUseCount", 0 )
	propertyBag:setProperty ( "RatedCurrentVersion", "NO" )
	propertyBag:setProperty ( "DeclinedToRate", "NO" )
	propertyBag:setProperty ( "ReminderRequestDate", os.time() )

print ( " ~ " ..	propertyBag:getProperty ( "DeclinedToRate" ) )


	if nil == propertyBag:GetFromFile() then propertyBag:SaveToFile() end

	incrementUseCount()
	if ratingConditionsHaveBeenMet() then print ("YES") end
	if ratingConditionsHaveBeenMet() then
		showRatingAlert()
	end

end

main()
