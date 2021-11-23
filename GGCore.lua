local b=1.00 local c='GGCore'if _G.GGCore then return end _G.GGUpdate={Callbacks={},DownloadFile=function(r,s,t)DownloadFileAsync(s,t,function()end)end,Trim=function(r,s)local t=s:match"^%s*()"return t>#s and""or s:match(".*%S",t)end,ReadFile=function(r,s)local t={}local u=io.open(s,"r")if u then for v in u:lines()do local w=r:Trim(v)if#w>0 then table.insert(t,w)end end u:close()end return t end,New=function(r,s)local t={Step=1,Version=type(s.version)=='number'and s.version or tonumber(s.version),VersionUrl=s.versionUrl,VersionPath=s.versionPath,ScriptUrl=s.scriptUrl,ScriptPath=s.scriptPath,ScriptName=s.scriptName,VersionType=s.versionType,VersionTimer=GetTickCount(),DownloadVersion=function(u)if not FileExist(u.ScriptPath)then u.Step=4 GGUpdate:DownloadFile(u.ScriptUrl,u.ScriptPath)u.ScriptTimer=GetTickCount()return end GGUpdate:DownloadFile(u.VersionUrl,u.VersionPath)end,CanUpdate=function(u,v)if u.VersionType==2 then if tonumber(v)>u.Version then return true end return false end local w=assert(load(v))()if w and type(w)=='table'then local x=w[u.ScriptName]if x then if x>u.Version then return true end end end return false end,OnTick=function(u)if u.Step==0 then return end if u.Step==1 then if GetTickCount()>u.VersionTimer+1 then local v=GGUpdate:ReadFile(u.VersionPath)if#v>0 and u:CanUpdate(v[1])then u.Step=2 u.NewVersion=v[1]GGUpdate:DownloadFile(u.ScriptUrl,u.ScriptPath)u.ScriptTimer=GetTickCount()else u.Step=3 end end end if u.Step==2 then if GetTickCount()>u.ScriptTimer+1 then u.Step=0 print(u.ScriptName..' - new update found! ['..tostring(u.Version)..' -> '..u.NewVersion..'] Please 2xf6!')end return end if u.Step==3 then u.Step=0 return end if u.Step==4 then if GetTickCount()>u.ScriptTimer+1 then u.Step=0 print(u.ScriptName..' - downloaded! Please 2xf6!')end end end,}if t.VersionType==nil then t.VersionType=2 end if t.VersionType>0 then t:DownloadVersion()end table.insert(r.Callbacks,t)end}GGUpdate:New({version=b,scriptName=c,scriptPath=COMMON_PATH..c..".lua",scriptUrl="https://raw.githubusercontent.com/gamsteron/GG/master/"..c..".lua",versionPath=COMMON_PATH.."GGVersion.lua",versionUrl="https://raw.githubusercontent.com/gamsteron/GG/master/GGVersion.lua",versionType=1,})do local r=false local s=false local t=0 s=Callback.Add("Tick",function()if t==0 then t=os.clock()+1 return end if os.clock()<t then return end if not r then local u=true for v=1,#GGUpdate.Callbacks do local w=GGUpdate.Callbacks[v]w:OnTick()if w.Step>0 then u=false end end if u then r=true end end end)end _G.GGCore=true _G.DownloadingGGCore=true if not FileExist(COMMON_PATH.."GGData.lua")then if not _G.DownloadingGGData then DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGData.lua",COMMON_PATH.."GGData.lua",function()end)print('GGData - downloaded! Please 2xf6!')_G.DownloadingGGData=true end return end require('GGData')if not FileExist(COMMON_PATH.."GGPrediction.lua")then if not _G.DownloadingGGPrediction then DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGPrediction.lua",COMMON_PATH.."GGPrediction.lua",function()end)print('GGPrediction - downloaded! Please 2xf6!')_G.DownloadingGGPrediction=true end return end require('GGPrediction')local d local e=Game.Resolution()local f=Draw.Text local g=Draw.Rect local h=Draw.Font('Arimo-Regular.ttf','Arimo')local i=Draw.Color(255,255,255,255)local j=Draw.Color(255,0,100,0)local k=Draw.Color(255,139,0,0)local l=Draw.Color(255,0,0,139)local m=Draw.Color(150,0,0,0)local n=Draw.Color(255,252,186,3)local o=Draw.Color(255,0,255,0)d={X=e.x*0.592435991,Y=e.y*0.608780119,MoveX=0,MoveY=0,Moving=false,Width=0,Height=0,Count=0,Groups={},ValidGroups={},MaxTitleWidth=0,MaxLabelWidth=0,MaxValueWidth=0,Margin=10,ItemSpaceX=75,ItemSpaceY=2,GroupSpaceY=12,PrintTitle=true,DefaultValueWidth=Draw.FontRect('Space',13,h).x+22,InfoPath=COMMON_PATH..'GGPermaShowInfo.lua',UpdateGroupPosition=function(r)r.Height=r.Margin*0.5 r.Width=r.Width+r.ItemSpaceX+r.Margin*2 for s=1,#r.ValidGroups do local t=r.ValidGroups[s]if d.PrintTitle then t.Title:UpdatePos()end for u=1,#t.Items do local v=t.Items[u]v:UpdatePos(r.Margin)if u<#t.Items then r.Height=r.Height+r.ItemSpaceY end end if s<#r.ValidGroups then r.Height=r.Height+r.GroupSpaceY end end r.Height=r.Height+r.Margin*0.5 r:OnHeightChange()end,OnWidthChange=function(r)local s=(r.X+r.Width)-e.x if s>0 then r.X=r.X-s r:Write()end end,OnHeightChange=function(r)local s=(r.Y+r.Height)-e.y if s>0 then r.Y=r.Y-s r:Write()end end,OnUpdate=function(r)r.MaxValueWidth=r.DefaultValueWidth for t=1,#r.ValidGroups do local u=r.ValidGroups[t]local v=u.Items for w=1,#v do local x=v[w]if x.Value.Width>r.MaxValueWidth then r.MaxValueWidth=x.Value.Width end end end local s=r.MaxLabelWidth+r.MaxValueWidth if d.PrintTitle and r.MaxTitleWidth>s then s=r.MaxTitleWidth end if s~=r.Width then r.Width=s r:OnWidthChange()end r:UpdateGroupPosition()end,OnItemChange=function(r)for t=#r.ValidGroups,1,-1 do table.remove(r.ValidGroups,t)end r.MaxTitleWidth=0 r.MaxLabelWidth=0 r.MaxValueWidth=r.DefaultValueWidth for t=1,#r.Groups do local u=r.Groups[t]local v=u.Items if#v>0 then table.insert(r.ValidGroups,u)local w=u.Title r.Height=r.Height+w.Height if w.Width>r.MaxTitleWidth then r.MaxTitleWidth=w.Width end for x=1,#v do local y=v[x]if y.Label.Width>r.MaxLabelWidth then r.MaxLabelWidth=y.Label.Width end if y.Value.Width>r.MaxValueWidth then r.MaxValueWidth=y.Value.Width end end end end local s=r.MaxLabelWidth+r.MaxValueWidth if d.PrintTitle and r.MaxTitleWidth>s then s=r.MaxTitleWidth end if s~=r.Width then r.Width=s r:OnWidthChange()end r:UpdateGroupPosition()end,WndMsg=function(r,s,t)if r.Count<1 then return end if s==513 and t==0 then local u,v,w,x=cursorPos.x,cursorPos.y,r.X,r.Y if u>=w and u<=w+r.Width then if v>=x and v<=x+r.Height then r.MoveX=w-u r.MoveY=x-v r.Moving=true end end end if s==514 and t==1 and r.Moving then r.Moving=false r:Write()end end,Draw=function(r)if r.Count<1 then return end if r.Moving then local s=cursorPos r.X=s.x+r.MoveX r.Y=s.y+r.MoveY end g(r.X,r.Y,r.Width,r.Height,m)for s=1,#r.ValidGroups do r.ValidGroups[s]:Draw()end end,Read=function(r)local s=io.open(r.InfoPath,'r')if s then local t=assert(load(s:read('*all')))()r.X,r.Y=t[1],t[2]s:close()end end,Write=function(r)local s=io.open(r.InfoPath,'w')if s then s:write('return{'..r.X..','..r.Y..'}')s:close()end end,Group=function(r,s,t)return{Id=s,Title=r:GroupTitle(t):Init(),Items={},Draw=function(u)if d.PrintTitle then u.Title:Draw()end for v=1,#u.Items do u.Items[v]:Draw()end end,}end,GroupTitle=function(r,s)return{X=0,Y=0,Name=s,UpdatePos=function(t)local u=d.Height t.X=(d.Width-d.MaxValueWidth-t.Width)/2 t.Y=u d.Height=t.Y+t.Height+3 end,Draw=function(t)f(t.Name,13,d.X+t.X,d.Y+t.Y,i,h)local u=d.X+t.X local v=d.Y+t.Y+t.Height+1 Draw.Line(u,v,u+t.Width,v,1,i)end,Init=function(t)local u=Draw.FontRect(t.Name,13,h)t.Width=u.x t.Height=u.y return t end,}end,GroupItem=function(r,s,t)return{X=0,Y=0,Label=r:ItemLabel(s),Value=r:ItemValue(),MenuItem=t,UpdatePos=function(u,v,w)local x=d.Height u.X=v u.Y=x d.Height=u.Y+u.Height u.Label:UpdatePos(u)u.Value:UpdatePos(u,v)end,Init=function(u)u.Label:Init()u.MenuItem.ParmaShowOnValueChange=function()u:Update()end u:Update()return u end,Draw=function(u)u.Label:Draw()u.Value:Draw()end,Update=function(u)u.Value:Update(u.MenuItem)u.Width=u.Label.Width+u.Value.Width u.Height=u.Label.Height>u.Value.Height and u.Label.Height or u.Value.Height d:OnUpdate()end,Dispose=function(u)u.MenuItem.ParmaShowOnValueChange=false end,}end,ItemLabel=function(r,s)return{X=0,Y=0,Name=s,UpdatePos=function(t,u)t.X=u.X t.Y=u.Y+(u.Height-t.Height)/2 end,Draw=function(t)f(t.Name,13,d.X+t.X,d.Y+t.Y,i,h)end,Init=function(t)local u=Draw.FontRect(t.Name,13,h)t.Width=u.x t.Height=u.y end,}end,ItemValue=function(r)return{X=0,Y=0,RectX=0,RectY=0,RectColor=l,UpdatePos=function(s,t,u)local v=0 s.RectX=d.Width-d.MaxValueWidth-u-v s.RectY=t.Y+(t.Height-s.Height)/2 s.RectWidth=d.Width-s.RectX-u s.RectHeight=s.Height s.X=s.RectX+(s.RectWidth-s.Width)/2 s.Y=s.RectY+(s.RectHeight-s.Height)/2 end,Draw=function(s)g(d.X+s.RectX,d.Y+s.RectY,s.RectWidth,s.RectHeight,s.RectColor)f(s.Name,13,d.X+s.X,d.Y+s.Y,i,h)end,Update=function(s,t)s.Value=t:GetValue()if t.Type~=4 then s.RectColor=s.Value and j or k end s.Name=t:ToString()local u=Draw.FontRect(s.Name,13,h)s.Width=u.x s.Height=u.y end,}end,AddGroup=function(r,s)table.insert(r.Groups,r:Group(s.Id,s.Name))return true end,AddItem=function(r,s,t)for u=1,#r.Groups do local v=r.Groups[u]if t.PermaShowID==v.Id then table.insert(v.Items,r:GroupItem(s,t):Init())r.Count=r.Count+1 r:OnItemChange()return true end end return false end,RemoveItem=function(r,s)for t=1,#r.Groups do local u=r.Groups[t]if u.Id==s.PermaShowID then for v=1,#u.Items do if u.Items[v].Value.Id==s.Id then u.Items[v]:Dispose()table.remove(u.Items,v)r.Count=r.Count-1 r:OnItemChange()return true end end end end return false end,}class'ScriptMenu'function ScriptMenu:__init(r,s,t,u,v,w,x,y)self.Id=r self.Name=s if t==nil then self.ElementCount=0 self.Settings={}self.Gos=MenuElement({type=_G.MENU,name=s,id=r})d:AddGroup(self)return end t.ElementCount=t.ElementCount+1 self.Type=u self.Parent=t if self.Type==0 then self.Gos=self.Parent.Gos:MenuElement({id='INFO_'..tostring(t.ElementCount),name=r or'',type=_G.SPACE})return end assert(self.Parent[self.Id]==nil,"menu: '"..self.Parent.Id.."' already contains '"..self.Id.."'")self.Parent[self.Id]=self if self.Type==1 then self.ElementCount=0 self.Gos=self.Parent.Gos:MenuElement({id=r,name=s,type=_G.MENU})else local z=self:GetRoot()assert(z.Settings[self.Id]==nil,"settings: '"..z.Id.."' already contains '"..self.Id.."'")self.Settings=z.Settings self.ParmaShowOnValueChange=false local A={id=r,name=s,type=_G.PARAM,callback=function(B)self.Settings[self.Id]=B if self.ParmaShowOnValueChange then self.ParmaShowOnValueChange()end end,}if self.Type==2 then A.value=v self.PermaShowID=z.Id elseif self.Type==3 then A.value=v A.min=w A.max=x A.step=y elseif self.Type==4 then A.value=v A.drop=w self.PermaShowID=z.Id self.DropList=w elseif self.Type==5 then A.color=v elseif self.Type==6 then assert(_G.type(v)=='string','ScriptMenu:KeyDown(id, name, key): [key] must be string')A.value=false A.key=string.byte(v)self.Key=v:upper()self.PermaShowID=z.Id A.onKeyChange=function(B)self.Key=string.char(B):upper()if self.ParmaShowOnValueChange then self.ParmaShowOnValueChange()end end elseif self.Type==7 then assert(_G.type(w)=='string','ScriptMenu:KeyToggle(id, name, value, key: [key] must be string')A.value=v A.key=string.byte(w)A.toggle=true self.Key=w:upper()self.PermaShowID=z.Id A.onKeyChange=function(B)self.Key=string.char(B):upper()if self.ParmaShowOnValueChange then self.ParmaShowOnValueChange()end end end self.Gos=self.Parent.Gos:MenuElement(A)if self.Type>=6 then self.Key=string.char(self.Gos.__key):upper()end self.Settings[self.Id]=self.Gos:Value()end end function ScriptMenu:Space(r,s)return ScriptMenu('',s,self,0)end function ScriptMenu:Info(r,s)return ScriptMenu(r,s,self,0)end function ScriptMenu:Menu(r,s)return ScriptMenu(r,s,self,1)end function ScriptMenu:OnOff(r,s,t)return ScriptMenu(r,s,self,2,t)end function ScriptMenu:Slider(r,s,t,u,v,w)return ScriptMenu(r,s,self,3,t,u,v,w)end function ScriptMenu:List(r,s,t,u)return ScriptMenu(r,s,self,4,t,u)end function ScriptMenu:Color(r,s,t)return ScriptMenu(r,s,self,5,t)end function ScriptMenu:KeyDown(r,s,t)return ScriptMenu(r,s,self,6,t)end function ScriptMenu:KeyToggle(r,s,t,u)return ScriptMenu(r,s,self,7,t,u)end function ScriptMenu:Hide(r)self.Gos:Hide(r)end function ScriptMenu:Remove()self.Gos:Remove()end function ScriptMenu:GetRoot()local r=self.Parent while true do if r.Parent==nil then break end r=r.Parent end return r end function ScriptMenu:ToString()if self.Type==4 then return self.DropList[self.Settings[self.Id]]end if self.Type>=6 then return self.Key==' 'and'Space'or self.Key end if self.Type==2 then return self.Settings[self.Id]and'On'or'Off'end return tostring(self.Settings[self.Id])end function ScriptMenu:GetValue()return self.Settings[self.Id]end function ScriptMenu:PermaShow(r,s)if self.Type==nil or self.Type<2 or self.Type==3 or self.Type==5 then return end if s==nil then s=true end if s then d:AddItem(r,self)else d:RemoveItem(self)end end d:Read()local function p()d:Draw()end local function q(r,s)d:WndMsg(r,s)end Callback.Add('Draw',p)Callback.Add('WndMsg',q)
