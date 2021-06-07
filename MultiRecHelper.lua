script_name('MultiRecHelper')
script_author('Kalgon')
script_moonloader('026')

-------------------------- lib -----------------------------

pcall(require, 'moonloader')
local dlstatus = require("moonloader").download_status
local limgui, imgui = pcall(require, 'imgui')
local sampev, sp = pcall(require, 'lib.samp.events')
local leff, effil = pcall(require, "effil")
local lmem, memory = pcall(require, 'memory')
local lkey, key = pcall(require, "vkeys")
local lini, inicfg = pcall(require, 'inicfg')
local lecod, encoding = pcall(require, 'encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8

---------------------- Переменные --------------------------

scinfo = [[
	Автор - Kalg0n

	Команды скрипта:
		/mrh (F9) - Открыть меню скрипта
		//rec - Реконнект
		//test - Тестовое сообщение в вк
]]

local cfg = {
	config={
		parol='';
		time_restart='09:05:00';
		auto_login=false;
		auto_pincod=false;
		rec_restart=false;
		home_lock=false;
		klad_find=false;
		lock_car=false;
		arzlaun=false;
		a_afk=false;
		vk_pay_day=false;
		vk_init_game=false;
		vk_crash_game=false;
		vk_crash_game=false;
		vk_notf=false;
		vk_listen=false;
		spass=false;
		pincod='';
		nick_name='';
		userid='',
	}
}
local d_ini = "..\\config\\MultiRec.ini"
local ini = inicfg.load(cfg, d_ini)
local dontshow_1 = true
local reloadR = false

local main_window_state = imgui.ImBool(false)
local auto_l = imgui.ImBool(ini.config.auto_login)
local auto_p = imgui.ImBool(ini.config.auto_pincod)
local pass_w = imgui.ImBuffer(''..ini.config.parol, 500) 
local rec_r = imgui.ImBool(ini.config.rec_restart)
local home_l = imgui.ImBool(ini.config.home_lock)
local klad = imgui.ImBool(ini.config.klad_find)
local lock_c = imgui.ImBool(ini.config.lock_car)
local arz_laun = imgui.ImBool(ini.config.arzlaun)
local aafk = imgui.ImBool(ini.config.a_afk)
local vk_payday = imgui.ImBool(ini.config.vk_pay_day)
local vk_initgame = imgui.ImBool(ini.config.vk_init_game)
local vk_crash = imgui.ImBool(ini.config.vk_crash_game)
local vknotf = imgui.ImBool(ini.config.vk_notf)
local vk_listen = imgui.ImBool(ini.config.vk_listen)
local spass = imgui.ImBool(ini.config.spass)
local pin_cod = imgui.ImBuffer(''..ini.config.pincod, 500)
local nick_n = imgui.ImBuffer(''..ini.config.nick_name, 500)
local user_id = imgui.ImBuffer(''..ini.config.userid, 500)

local scr_vers = 1
local scr_vers_text = "1.00"

local upd_url = "https://raw.githubusercontent.com/Kalg0n/MRH/main/updmrh.ini"
local upd_path = getWorkingDirectory() .. "/updmrh.ini"

local scr_url = ""
local scr_path = thisScript().path

upd_state = false

------------------------- Body -----------------------------

function main()
	while not isSampAvailable() do wait(0) end
	result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	player_name = sampGetPlayerNickname(id)
	
	
	downloadUrlToFile(upd_url, upd_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil, upd_path)
			if tonumber(updateIni.info.vers) > scr_vers then
				sampAddChatMessage("[MRH] Скачиваю новое обновление {ff0000}" .. updateIni.info.vers_text, -1)
				upd_state = true
			end
			os.remove(upd_path)
		end
	end)

	sampRegisterChatCommand("/rec", function()
		sampDisconnectWithReason(false)
		sampSetGamestate(1)
	end)
	sampRegisterChatCommand("/test", function()
		sendvknotf('\nТестовое сообщение...')
	end)
	sampRegisterChatCommand("MRH", function()
		main_window_state.v = not main_window_state.v
		imgui.Process = main_window_state.v
	end)
	a_afk()
	lua_thread.create(vkget)
	while true do
		wait(0)
		if upd_state then
			downloadUrlToFile(scr_url, scr_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage("[MRH] Обновление успешно загружено.")
					thisScript():reload()
				end
			end)
		end
		if isKeyDown(VK_F9) and isKeyCheckAvailable() then
			main_window_state.v = not main_window_state.v
			imgui.Process = main_window_state.v
			wait(250)
		end
		if reloadR == true then
			reloadR = false
			inicfg.save(cfg, d_ini)
		end
		if ini.config.rec_restart then
			if ini.config.time_restart == os.date('%H:%M:%S') then
				sampDisconnectWithReason(false)
				wait(2500)
				sampSetGamestate(1)
			end
		end
		local chat = sampGetChatString(99)
		if chat == "Wrong server password." then
		sampDisconnectWithReason(false)
			wait(2500)
			sampSetGamestate(1)
		end
		if not sampIsChatInputActive() and lock_c.v and testCheat("l") then
			sampSendChat("/lock")
		end
		if testCheat("hj") and not sampIsChatInputActive() and home_l.v then
			homejoin()
		end
		if arz_laun.v then
			function sp.onSendClientJoin(Ver, mod, nick, response, authKey, clientver, unk)
				clientver = 'Arizona PC'
				return {Ver, mod, nick, response, authKey, clientver, unk}
			end
		end
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		inicfg.save(cfg, d_ini)
		if vk_crash.v and vknotf.v then
			sendvknotf('\nСкрипт умер')
		end
	end
end

function nopHook(name, bool)
    local samp = require 'samp.events'
    samp[name] = function()
        if bool then return false end
    end
end
function homejoin() -- Чит код HJ
	nopHook("onShowDialog", true)
	sampSendChat("/house")
	sampSendDialogResponse(174, 1, 0, -1)
	setGameKeyState(21, 255)
	wait(1)
	sampSendChat("/house")
	sampSendDialogResponse(174, 1, 0, -1)
	wait(500)
	nopHook("onShowDialog", false)
end
function isKeyCheckAvailable()
	if not isSampLoaded() then
		return true
	end
	if not isSampfuncsLoaded() then
		return not sampIsChatInputActive() and not sampIsDialogActive()
	end
	return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()
end


lua_thread.create(function()  ---- CTRL + R
	while true do
		wait(30)
		if isKeyDown(17) and isKeyDown(82) then
			reloadR = true
			inicfg.save(cfg, d_ini)
		end
	end
end)

function sp.onShowDialog(id, style, title, button1, button2, text) ------ Диалог
	if auto_l.v and id == (2) and nick_n.v == player_name then
        sampSendDialogResponse(id, 1, _, ini.config.parol)
        return false
    end
	if auto_p.v and id == (991) then
	sampSendDialogResponse(id, 1, _, ini.config.pincod)
		return false
	end
	if sendstatsstate and id == 235 then
		sampSendDialogResponse(id,0,0,'')
		sendstatsstate = text
		return false
	end
end
function sp.onCreateObject(objectId, data)
    if data.modelId == 2680 and klad.v then
        sampAddChatMessage('[MRH] {ff0000}Найден клад, {ffffff}метка отмечена на карте', -1)
        placeWaypoint(data.position.x, data.position.y, data.position.z)
    end
end
function sp.onServerMessage(color, text) ------ Текст
	lua_thread.create(function()
		if vknotf.v and vk_initgame.v then
			if text:find("На сервере есть инвентарь, используйте клавишу Y для работы") then
				sendvknotf('\nВы подключились к серверу!')
			end
		end
		if text:find("Попробуйте переподключиться через (%d+)") then
		temp1 = text:match("Попробуйте переподключиться через (%d+)")
			wait(0)
			sampAddChatMessage("[MRH] {ffffff}Включено автоматическое переподключение через {ff6161}"..temp1.."сек.", -1)
			if vk_initgame.v and vknotf.v then
				sendvknotf("\nПереподключение через: ".. temp1 .." сек.")
			end
			wait(temp1 * 950)
		sampDisconnectWithReason(false)
			wait(50)
			sampSetGamestate(1)
		end
		if vk_payday.v and vknotf.v then
			if text:find('Банковский чек') and color == 1941201407 then
				ispaydaystate = true
				ispaydaytext = ''
			end
		end
		if ispaydaystate then
			if text:find('Депозит в банке') then 
				ispaydaytext = ispaydaytext..'\n___PayDay___\n'..text
			elseif text:find('Сумма к выплате') then
				ispaydaytext = ispaydaytext..'\n'..text 
			elseif text:find('Текущая сумма на депозите') then
				ispaydaytext = ispaydaytext..'\n'..text
				sendvknotf(ispaydaytext)
				ispaydaystate = false
				ispaydaytext = ''
			end
		end
		if vk_listen.v and vknotf.v then
			if not text:find('News') and not text:find('СМИ') and not text:find('Объявление:') then
				sendvknotf('\n'..text)
			end
		end
    end)
end

------------------------------ IMGUI ------------------------------------------

menunum = 0

function imgui.OnDrawFrame()
	imgui.ShowCursor = main_window_state.v
	if main_window_state.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(870, 320), imgui.Cond.FirstUseEver)
	  imgui.Begin('MultiRecHelper | Kalg0n', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
	if menunum > 0 then
		imgui.SetCursorPos(imgui.ImVec2(10,24))
		if imgui.Button('HA3AD',imgui.ImVec2(50,20)) then
			menunum = 0
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(0,50))
	imgui.Separator()
	if menunum == 0 then
		local buttons = {
			{u8('Помощник'),1,u8('Настройка помощника')},
			{u8('Настройки'),2,u8('Настройка основных функций')},
			{u8('Управление'),3,u8('Управление функций')},
			{u8('Vk notf'),4,u8('Настройка уведомлений ВК')},
			{u8('Информация'),5,u8('Информация о скрипте')},
			{u8('Сохранить'),6,u8('Сохраняет все настройки')}
		}
		local function renderbutton(i)
			local name,set,desc,func = buttons[i][1],buttons[i][2],buttons[i][3],buttons[i][4]
			local getpos2 = imgui.GetCursorPos()
			imgui.SetCursorPos(getpos2)
			if imgui.Button('##'..name..'//'..desc,imgui.ImVec2(240,80)) then
				if func then
					pcall(func)
				else
					menunum = set
				end
			end 
			imgui.SetCursorPos(getpos2)
			imgui.BeginGroup()
			imgui.CreatePadding(240/2-imgui.CalcTextSize(name).x/2,15)
			imgui.Text(name)
			imgui.CreatePadding(240/2-imgui.CalcTextSize(desc).x/2,(80/2-imgui.CalcTextSize(desc).y/2)-25)
			imgui.Text(desc)
			imgui.EndGroup()
			imgui.SetCursorPos(imgui.ImVec2(getpos2.x,getpos2.y+90))
		end
		imgui.CreatePaddingY(20)
		local cc = 1
		local startY = 90 
		for i = 1, #buttons do
			local poss = {
				80,
				330,
				580
			}
			imgui.SetCursorPos(imgui.ImVec2(poss[cc],startY))
			renderbutton(i)
			if cc == #poss then
				cc = 0
				startY = startY + 90
			end
			cc = cc + 1
		end
	elseif menunum == 1 then
		imgui.BeginChild("##setting", imgui.ImVec2(-1,-1), false, imgui.WindowFlags.NoScrollbar)
				imgui.CenterText(u8(''))
				imgui.Separator()
				imgui.NewLine()
				if imgui.Checkbox(u8"Вход домой (HJ)##home_l", home_l) then
					ini.config.home_lock = home_l.v
					inicfg.save(cfg, d_ini)
				end
				imgui.SameLine()
				if imgui.Checkbox(u8"Клады в чат##klad", klad) then
					ini.config.klad_find = klad.v
					inicfg.save(cfg, d_ini)
				end
				imgui.SameLine()
				if imgui.Checkbox(u8"Закрытие т/c (L)##lock_c", lock_c) then
					ini.config.lock_car = lock_c.v
					inicfg.save(cfg, d_ini)
				end
				imgui.SameLine()
				if imgui.Checkbox(u8"Анти-афк##aafk", aafk) then
					ini.config.a_afk = aafk.v
					inicfg.save(cfg, d_ini)
					if aafk.v then
						sampAddChatMessage("[MRH] antiafk Вкл.", -1)
						memory.setuint8(7634870, 1, false)
						memory.setuint8(7635034, 1, false)
						memory.fill(7623723, 144, 8, false)
						memory.fill(5499528, 144, 6, false)
					else
						sampAddChatMessage("[MRH] antiafk Выкл.", -1)
						memory.setuint8(7634870, 0, false)
						memory.setuint8(7635034, 0, false)
						memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
						memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
					end
				end
		imgui.EndChild()
	elseif menunum == 2 then
		imgui.BeginChild("##full_dostup", imgui.ImVec2(-1,-1), false, imgui.WindowFlags.NoScrollbar)
				imgui.CenterText(u8(''))
				imgui.Separator()
				imgui.NewLine()
				if imgui.Checkbox(u8"Авто-ввод логина##auto_l", auto_l) then
					ini.config.auto_login = auto_l.v
					inicfg.save(cfg, d_ini)
				end
				imgui.SameLine()
				if imgui.Checkbox(u8"Авто-ввод пин-кода##auto_p", auto_p) then
					ini.config.auto_pincod = auto_p.v
					inicfg.save(cfg, d_ini)
				end
				imgui.SameLine()
				if imgui.Checkbox(u8"Рекон. в рестарт##rec_r", rec_r) then
					ini.config.rec_restart = rec_r.v
					inicfg.save(cfg, d_ini)
				end
				imgui.SameLine()
				if imgui.Checkbox(u8"Эмулятор лаунчера##arz_laun", arz_laun) then
					ini.config.arzlaun = arz_laun.v
					inicfg.save(cfg, d_ini)
					if arz_laun.v then
						sampAddChatMessage("[MRH] Для работы эмулятора, {ff6161}ПЕРЕЗАЙДИТЕ '//rec'.", -1)
						sampAddChatMessage("[MRH] Для работы эмулятора, {ff6161}ПЕРЕЗАЙДИТЕ '//rec'.", -1)
						sampAddChatMessage("[MRH] Для работы эмулятора, {ff6161}ПЕРЕЗАЙДИТЕ '//rec'.", -1)
					end
				end
		imgui.EndChild()
	elseif menunum == 3 then
		imgui.BeginChild("##control", imgui.ImVec2(-1,-1), false, imgui.WindowFlags.NoScrollbar)
				imgui.CenterText(u8(''))
				imgui.Separator()
				imgui.NewLine()
				imgui.PushItemWidth(200)
				if imgui.InputText(u8"Ваш Ник##nick_n", nick_n) then
					ini.config.nick_name = nick_n.v
					inicfg.save(cfg, d_ini)
				end
				imgui.PopItemWidth()
				imgui.NewLine(2)
				imgui.PushItemWidth(70)
				if imgui.InputText(u8"Пароль", pass_w, dontshow_1 and imgui.InputTextFlags.Password or 0) then
					ini.config.parol = pass_w.v
					inicfg.save(cfg, d_ini)
				end
				imgui.SameLine()
				if imgui.InputText(u8"Пинкод", pin_cod, dontshow_1 and imgui.InputTextFlags.Password or 0) then
					ini.config.pincod = pin_cod.v
					inicfg.save(cfg, d_ini)
				end
				imgui.PopItemWidth()
		imgui.EndChild()
	elseif menunum == 4 then
		imgui.BeginChild("##vk", imgui.ImVec2(-1, -1), false, imgui.WindowFlags.NoScrollbar)
				imgui.CenterText(u8('Settings'))
				imgui.Separator()
				imgui.NewLine()
				if imgui.Checkbox(u8"Включить уведомления.##vknotf", vknotf) then
					ini.config.vk_notf = vknotf.v
					inicfg.save(cfg, d_ini)
				end
				imgui.NewLine()
				if vknotf.v then
					imgui.BeginGroup()
					imgui.PushItemWidth(150)
					if imgui.InputText(u8"Ид своей страницы##user_id", user_id) then
						ini.config.userid = user_id.v
						inicfg.save(cfg, d_ini)
					end
					imgui.NewLine()
					if imgui.Checkbox(u8"PayDay##vk_payday", vk_payday) then
						ini.config.vk_pay_day = vk_payday.v
						inicfg.save(cfg, d_ini)
					end
					imgui.SameLine()
					if imgui.Checkbox(u8"Подключение##vk_initgame", vk_initgame) then
						ini.config.vk_init_game = vk_initgame.v
						inicfg.save(cfg, d_ini)
					end
					imgui.SameLine()
					if imgui.Checkbox(u8"Краш скрипта##vk_crash", vk_crash) then
						ini.config.vk_crash_game = vk_crash.v
						inicfg.save(cfg, d_ini)
					end
					imgui.SameLine()
					if imgui.Checkbox(u8"Чат игры в вк##vk_listen", vk_listen) then
						ini.config.vk_listen = vk_listen.v
					end
					imgui.EndGroup()
				end
		imgui.EndChild()
	elseif menunum == 5 then
		imgui.BeginChild("##info", imgui.ImVec2(-1, -1), false, imgui.WindowFlags.NoScrollbar)
				imgui.CenterText(u8('Info'))
				imgui.Separator()
				imgui.NewLine()
				imgui.Text(u8(scinfo))
		imgui.EndChild()
	elseif menunum == 6 then
		imgui.BeginChild("##save", imgui.ImVec2(-1, -1), false, imgui.WindowFlags.NoScrollbar)
				imgui.CenterText(u8('Save'))
				imgui.Separator()
				imgui.NewLine()
				imgui.Text(u8"                         Успешно сохранено!")
		imgui.EndChild()
	end
	  imgui.End()
	end
	imgui.SwitchContext()
	-------------------- Style -------------------
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4
	colors[imgui.Col.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[imgui.Col.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[imgui.Col.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[imgui.Col.WindowBg] = ImVec4(0.11, 0.10, 0.11, 1.00)
	colors[imgui.Col.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[imgui.Col.PopupBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[imgui.Col.Border] = ImVec4(0.86, 0.86, 0.86, 1.00)
	colors[imgui.Col.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[imgui.Col.Header] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.HeaderHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.HeaderActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.MenuBarBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.FrameBg] = ImVec4(0.21, 0.20, 0.21, 0.60)
	colors[imgui.Col.FrameBgHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.FrameBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.TitleBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.TitleBgCollapsed] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.TitleBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[imgui.Col.Button] = ImVec4(0.36, 0.36, 0.36, 0.40);
	colors[imgui.Col.ButtonHovered] = ImVec4(0.00, 0.46, 0.65, 0.80)
	colors[imgui.Col.ButtonActive] = ImVec4(0.00, 0.46, 0.65, 0.60)

	style.WindowPadding = imgui.ImVec2(8, 8)
	style.WindowRounding = 4
	style.ChildWindowRounding = 5
	style.FramePadding = imgui.ImVec2(5, 3)
	style.FrameRounding = 3.0
	style.ItemSpacing = imgui.ImVec2(5, 4)
	style.ItemInnerSpacing = imgui.ImVec2(4, 4)
	style.IndentSpacing = 21
	style.ScrollbarSize = 10.0
	style.ScrollbarRounding = 13
	style.GrabMinSize = 8
	style.GrabRounding = 1
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
end

function onWindowMessage(msg, wparam, lparam)
    if msg == 0x100 or msg == 0x101 then
        if wparam == key.VK_ESCAPE and main_window_state.v then
            consumeWindowMessage(true, false)
            if msg == 0x101 then
				main_window_state.v = false
				menunum = 0
			end
        end
    end
end
function imgui.CreatePaddingY(y)
	y = y or 8
	local cc = imgui.GetCursorPos()
	imgui.SetCursorPosY(cc.y+y)
end
function imgui.CreatePaddingX(x)
	x = x or 8
	local cc = imgui.GetCursorPos()
	imgui.SetCursorPosX(cc.x+x)
end
function imgui.CreatePaddingY(y)
	y = y or 8
	local cc = imgui.GetCursorPos()
	imgui.SetCursorPosY(cc.y+y)
end
function imgui.CreatePadding(x,y)
	x,y = x or 8, y or 8
	local cc = imgui.GetCursorPos()
	imgui.SetCursorPos(imgui.ImVec2(cc.x+x,cc.y+y))
end
function imgui.CenterText(text) 
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function a_afk()
	if aafk.v then
        memory.setuint8(7634870, 1, false)
        memory.setuint8(7635034, 1, false)
        memory.fill(7623723, 144, 8, false)
        memory.fill(5499528, 144, 6, false)
	else
		memory.setuint8(7634870, 0, false)
        memory.setuint8(7635034, 0, false)
        memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
        memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
	end
end

-- // система автообновления







menufill = 0 
localvalue = 0
local key, server, ts

local group_id = '198154439'

function vkget()
	longpollGetKey()
	local reject, args = function() end, ''
	while not key do 
		wait(1)
	end
	local runner = requestRunner()
	while true do
		while not key do wait(0) end
		url = server .. '?act=a_check&key=' .. key .. '&ts=' .. ts .. '&wait=25' --меняем url каждый новый запрос потокa, так как server/key/ts могут изменяться
		threadHandle(runner, url, args, longpollResolve, reject)
		wait(100)
	end
end

function threadHandle(runner, url, args, resolve, reject) -- обработка effil потока без блокировок
	local t = runner(url, args)
	local r = t:get(0)
	while not r do
		r = t:get(0)
		wait(0)
	end
	local status = t:status()
	if status == 'completed' then
		local ok, result = r[1], r[2]
		if ok then resolve(result) else reject(result) end
	elseif err then
		reject(err)
	elseif status == 'canceled' then
		reject(status)
	end
	t:cancel(0)
end
function requestRunner() -- создание effil потока с функцией https запроса
	return effil.thread(function(u, a)
		local https = require 'ssl.https'
		local ok, result = pcall(https.request, u, a)
		if ok then
			return {true, result}
		else
			return {false, result}
		end
	end)
end
function async_http_request(url, args, resolve, reject)
	local runner = requestRunner()
	if not reject then reject = function() end end
	lua_thread.create(threadHandle,runner, url, args, resolve, reject)
end
local vkerr, vkerrsend -- сообщение с текстом ошибки, nil если все ок
function tblfromstr(str)
	local a = {}
	for b in str:gmatch('%S+') do
		a[#a+1] = b
	end
	return a
end
function longpollResolve(result)
	if result then
		if not result:sub(1,1) == '{' then
			vkerr = 'Ошибка!\nПричина: Нет соединения с VK!'
			return
		end
		local t = decodeJson(result)
		if t.failed then
			if t.failed == 1 then
				ts = t.ts
			else
				key = nil
				longpollGetKey()
			end
			return
		end
		if t.ts then
			ts = t.ts
		end
		if t.updates then
			for k, v in ipairs(t.updates) do
				if v.type == 'message_new' and tonumber(v.object.from_id) == tonumber(user_id.v) and v.object.text then
					if v.object.payload then
						local pl = decodeJson(v.object.payload)
						if pl.button then
							if pl.button == 'stats' then
								getPlayerArzStats()
							elseif pl.button == 'pinfo' then
								getPlayerInfo()
							elseif pl.button == 'help' then
								sendvknotf("\nКоманды:\n chat [комманда] - Отправка сообщения в чат\n stats - статистика игрока.\n pinfo - информация о игроке.\n listen - прослушка чата.")
							end
						end
						return
					end
					local objsend = tblfromstr(v.object.text)
					if objsend[1] == 'stats' then
						getPlayerArzStats()
					elseif objsend[1] == 'pinfo' then
						sendvknotf("\nИнформация о игроке")
					elseif objsend[1] == 'listen' then
						vk_listen.v = not vk_listen.v
						ini.config.vk_listen = vk_listen.v
						if vk_listen.v and vknotf.v then
							sendvknotf("\nПрослушка включена")
						else
							sendvknotf("\nПрослушка выключена")
						end
					elseif objsend[1] == 'help' then
						sendvknotf("\nКоманды:\n chat [комманда] - Отправка сообщения в чат\n stats - статистика игрока.\n pinfo - информация о игроке.\n listen - прослушка чата.")
					elseif objsend[1] == 'chat' then
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampProcessChatInput(args)
							sendvknotf('\nСообщение "' .. args .. '" успешно отправлено')
						else
							sendvknotf('\nОшибка')
						end
					end
				end
			end
		end
	end
end
function longpollGetKey()
	async_http_request('https://api.vk.com/method/groups.getLongPollServer?group_id=' .. group_id .. '&access_token=ac66fe80f89adbe520ef7348f63f2d46622d14fd7b6bd2e441cc8562a83b57cd02434a5f5cfc100d822f0&v=5.80', '', function (result)
		if result then
			if not result:sub(1,1) == '{' then
				vkerr = 'Ошибка!\nПричина: Нет соединения с VK!'
				return
			end
			local t = decodeJson(result)
			if t then
				if t.error then
					vkerr = 'Ошибка!\nКод: ' .. t.error.error_code .. ' Причина: ' .. t.error.error_msg
					return
				end
				server = t.response.server
				ts = t.response.ts
				key = t.response.key
				vkerr = nil
			end
		end
	end)
end

function sendvknotf(msg, host)
	host = host or sampGetCurrentServerName()
	local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) .. '['..select(2,sampGetPlayerIdByCharHandle(playerPed))..']'
	msg = msg:gsub('{......}', '')
	msg = acc..'\n'..msg
	msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = vkKeyboard()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if #user_id.v > 0 then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. user_id.v .. '&message=' .. msg .. '&access_token=ac66fe80f89adbe520ef7348f63f2d46622d14fd7b6bd2e441cc8562a83b57cd02434a5f5cfc100d822f0&v=5.80',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = 'Ошибка!\nКод: ' .. t.error.error_code .. ' Причина: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function vkKeyboard() --создает конкретную клавиатуру для бота VK, как сделать для более общих случаев пока не задумывался
	local keyboard = {}
	keyboard.one_time = false
	keyboard.buttons = {}
	keyboard.buttons[1] = {}
	local row = keyboard.buttons[1]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "pinfo"}'
	row[1].action.label = 'Информация'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "stats"}'
	row[2].action.label = 'Статистика'
	row[3] = {}
	row[3].action = {}
	row[3].color = 'positive'
	row[3].action.type = 'text'
	row[3].action.payload = '{"button": "help"}'
	row[3].action.label = 'Помощь'
	return encodeJson(keyboard)
end
function char_to_hex(str)
	return string.format("%%%02X", string.byte(str))
  end
  
function url_encode(str)
    local str = string.gsub(str, "\\", "\\")
    local str = string.gsub(str, "([^%w])", char_to_hex)
    return str
end

function getPlayerInfo()
	sampAddChatMessage('Недоступно', -1)
	sendvknotf('\nНедоступно')
end

sendstatsstate = false
function getPlayerArzStats()
	if sampIsLocalPlayerSpawned() then
		sendstatsstate = true
		sampSendChat('/stats')
		local timesendrequest = os.clock()
		while os.clock() - timesendrequest <= 10 do
			wait(0)
			if sendstatsstate ~= true then
				timesendrequest = 0
			end 
		end
		sendvknotf(sendstatsstate == true and 'Ошибка! В течении 10 секунд скрипт не получил информацию!' or tostring('\n'..sendstatsstate))
		sendstatsstate = false
	else
		sendvknotf('\nПерсонаж не заспавнен')
	end
end