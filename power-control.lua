-- Basic control for BigReactors-Reactor
-- BSD3 License
-- Emily Backes <lucca@accela.net>

-- Uses the first monitor it finds, if any
-- May need 3x3 or larger for that
-- No log output or printer usage yet
-- Will work on adv comps but mouse event handling
--   would need to be added below
-- Suitable for use in /startup

-- Max energy in a reactor's internal cell
local emax=10000000

-- wrap everything in an exception handler
local ok,msg=pcall(function ()
local r
local m
local p

function findDev (dType)
  local d
  for _,d in pairs(peripheral.getNames()) do
    if (peripheral.getType(d) == dType) then
      return peripheral.wrap(d)
    end
  end
  return nil, dType..": not found"
end

function setupDevs()
  r=assert(findDev("BigReactors-Reactor"))
  if (not r.getConnected()) then
    return nil, "Computer port not connected to a valid reactor"
  end
  --if (r.getNumberOfControlRods() <1) then
  --  return nil, "Reactor seems invalid"
  --end
  r.getEnergyPercent = function ()
    return math.floor(1000 * r.getEnergyStored() / emax)/10
  end
  if r.nativeEPLT then
    r.getEnergyProducedLastTick = r.nativeEPLT
  end
  r.nativeEPLT = r.getEnergyProducedLastTick
  r.getEnergyProducedLastTick = function ()
    return math.floor(r.nativeEPLT()*1000)/1000
  end

  term.redirect(term.native())
  m=findDev("monitor")
  if m then
    m.setTextScale(0.5)
    term.clear()
    term.setCursorPos(1,1)
    print("Redirecting to attached monitor")
    term.redirect(m)
  end

  term.setCursorBlink(false)
  p=findDev("printer")
end

function ft ()
  local d=os.day()
  local t=os.time()
  local h=math.floor(t)
  local m=math.floor((t-h)*60)
  return string.format("Day %d, %02d:%02d",d,h,m)
end

function log (msg)
  local stamp=ft()
  print (stamp..": "..msg)
end

function tableWidth(t)
  local width=0
  for _,v in pairs(t) do
    if #v>width then width=#v end
  end
  return width
end

function ljust(s,w)
  local pad=w-#s
  return s .. string.rep(" ",pad)
end

function rjust(s,w)
  local pad=w-#s
  return string.rep(" ",pad) .. s
end

function display()
  term.clear()
  term.setCursorPos(1,1)
  print("Reactor Status")
  print(ft())
  print("")
  local funcs={"Connected","Active","NumberOfControlRods","EnergyStored","FuelTemperature","FuelAmount","WasteAmount","FuelAmountMax","EnergyProducedLastTick"}
  local units={"","","","RF","C","mB","mB","mB","RF/t"}
  local values={}
  for _,v in pairs(funcs) do
    values[#values+1] = tostring(r["get"..v]())
  end
  local funcW=tableWidth(funcs)
  local valW=tableWidth(values)
  for i,v in pairs(funcs) do
    print(rjust(v,funcW)..": "..rjust(values[i],valW).." "..units[i])
  end
end

log("Starting")
setupDevs()
while true do
  local e=r.getEnergyStored()
  local p=math.floor(100*e/emax)
  local a=p<100
  local elt=r.getEnergyProducedLastTick()
  display()
  r.setAllControlRodLevels(p)
  r.setActive(a)
  os.startTimer(0.8333334)
  local event,p1,p2,p3,p4,p5 = os.pullEvent()
  if event == "key" then
    break
  elseif event == "peripheral_detach" or event == "peripheral" or event == "monitor_resize" then
    setupDevs()
  elseif not (event == "timer" or event=="disk" or event=="disk_eject") then
    error("received "..event)
  end
end

end)
term.redirect(term.native())
error(msg)
