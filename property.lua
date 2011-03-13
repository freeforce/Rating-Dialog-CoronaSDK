module(..., package.seeall)

-- Returns a valid object to work with
function init ( )
	local g = {}
	local _properties={}
	local filePath = system.pathForFile( "defaults", system.DocumentsDirectory )
	
	--Helper Functions Forward Declaration	
	local doesFileExist={}
	local SaveToFile={}
	local GetFromFile={}
	
	--SET Properties
	function g:setProperty ( name, value )
	--print ( name .. " = " .. value )
	 	_properties[name] = value
	end

	--GET Properties	
	function g:getProperty ( name, defaultValue )
		local defaultValue = defaultValue or ""
		
		if _properties[name] == nil then
			g:setProperty( name, defaultValue)	
		end
		 
		return _properties[name]
	end

	function g:removeProperty ( name )
	 --Remove this item
	 --TODO: 2 B implemented.
	end


	--Useful for debugging, Prints all the tables
	function g:printTable ()
	   for k,v in pairs ( _properties ) do
		 print ( " --> " .. k .. " = " .. v )
	   end
	end	

----------HELPER FUNCTIONS ----------------------


----------------------------------
	--Does a file Exist in the given path?
	doesFileExist = function ( theFile )
		local datafile		
		datafile = io.open ( theFile )
		if datafile == nil then
			return false
		else
			datafile:close()
			return true
		end
	end

----------------------------------
	--Split function
	function string:split(sep)
			local sep, fields = sep or ":", {}
			local pattern = string.format("([^%s]+)", sep)
			self:gsub(pattern, function(c) fields[#fields+1] = c end)
			return fields
	end

	--This is similar to the PHP Explode function
	local function explode(d,p)
	  local t, ll
	  t={}
	  ll=0
	  if(#p == 1) then return {p} end
		while true do
		  l=string.find(p,d,ll,true) -- find the next d in the string
		  if l~=nil then -- if "not not" found then..
			table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
			ll=l+1 -- save just after where we found it for searching next time.
		  else
			table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
			break -- Break at end, as it should be, according to the lua manual.
		  end
		end
	  return t
	end

----------------------------------
	--Save the defaults to a file
	function g:SaveToFile ()
		local datafile, errStr
		datafile, errStr = io.open( filePath, "w+" )
			if not errStr == nil then
				print ( "Error occurred" )
			end
				print ( "saving to file..." )
				for k,v in pairs(_properties) do
					----print ( "< " .. k .. " = " .. v )
					datafile:write ( k .. "=" .. v .. "\n" )
				end
		datafile:close()
	end


----------------------------------
	--Load defaults from a file
	function g:GetFromFile  ()
		local theLine, theLineValue
		local datafile, errStr, line
		----print ( "Loading data from the file" )
		
		datafile, errStr = io.open ( filePath )
		if datafile == nil then
			print ( "err " .. errStr )
			return nil
		else
			for line in datafile:lines( ) do
				----print ( line )
				theLine = explode( "=" , line )
				----print ( "data split " .. theLine[1] .. " = " .. theLine[2] )
				g:setProperty ( theLine[1] , theLine[2] )
			end
			datafile:close()
		end
		
	end
------------END OF ALL HELPER FUNCTIONS ---------------------

	--Load from the File, if the file exists
	if doesFileExist ( filePath ) then
		g:GetFromFile()
	end

	return g
end

