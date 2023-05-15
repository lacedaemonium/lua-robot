stopped = false
function OnStop()
	stopped = true
	return 5000
end

function shortROSNlongLKOH(x,y)
	ROSN = {
		ACTION = 'NEW_ORDER',
		ACCOUNT = 'SPBFUTJRoA1',
		OPERATION = 'S',
		CLASSCODE = 'SPBFUT',
		SECCODE = 'RNM1',
		PRICE = tostring(0),
		QUANTITY = tostring(x),
		TRANS_ID = tostring(1000),
		TYPE = 'M'
		}
	local ROSNres = sendTransaction(ROSN)
	LKOH = {
		ACTION = 'NEW_ORDER',
		ACCOUNT = 'SPBFUTJRoA1',
		OPERATION = 'B',
		CLASSCODE = 'SPBFUT',
		SECCODE = 'LKM1',
		PRICE = tostring(0),
		QUANTITY = tostring(y),
		TRANS_ID = tostring(1000),
		TYPE = 'M'
		}
	local LKOHres = sendTransaction(LKOH)
	return 1
end

function longROSNshortKOH(x,y)
	ROSN = {
		ACTION = 'NEW_ORDER',
		ACCOUNT = 'SPBFUTJRoA1',
		OPERATION = 'B',
		CLASSCODE = 'SPBFUT',
		SECCODE = 'RNM1',
		PRICE = tostring(0),
		QUANTITY = tostring(x),
		TRANS_ID = tostring(1000),
		TYPE = 'M'
		}
	local ROSNres = sendTransaction(ROSN)
	LKOH = {
		ACTION = 'NEW_ORDER',
		ACCOUNT = 'SPBFUTJRoA1',
		OPERATION = 'S',
		CLASSCODE = 'SPBFUT',
		SECCODE = 'LKM1',
		PRICE = tostring(0),
		QUANTITY = tostring(y),
		TRANS_ID = tostring(1000),
		TYPE = 'M'
		}
	local LKOHres = sendTransaction(LKOH)
	return 1
end

function main()

	NumCandlesROSNLast = 0
	NumCandlesLKOHLast = 0

	--schitaem svechi na grafike raz v secundu
	while true do
	
		NumCandlesROSN = getNumCandles('ROSN')
		NumCandlesLKOH = getNumCandles('LKOH')
		sleep(1*1000)
		--esli novaya svecha
		--if (NumCandlesROSN > NumCandlesROSNLast) and (NumCandlesLKOH > NumCandlesLKOHLast) then
		if (NumCandlesROSN > NumCandlesROSNLast) or (NumCandlesLKOH > NumCandlesLKOHLast) then
			--у нас новая свеча! работаем'
			NumCandlesROSNLast = NumCandlesROSN
			NumCandlesLKOHLast = NumCandlesLKOH
			
			--берем число свечей и свечи
			NumCandlesROSN = getNumCandles('ROSN')
			ROSN, ROSNi, ROSNName = getCandlesByIndex('ROSN', 0, 0, NumCandlesROSN)
			ROSNLastCandlePriceClose = ROSN[ROSNi-1].close
			
			NumCandlesLKOH = getNumCandles('LKOH')
			LKOH, LKOHi, LKOHName = getCandlesByIndex('LKOH', 0, 0, NumCandlesLKOH)
			LKOHLastCandlePriceClose = LKOH[LKOHi-1].close
			
			--разница цен активов
			Delta = ROSNLastCandlePriceClose-LKOHLastCandlePriceClose
			--message('разница цен активов: '..Delta)

			--средняя цена активов
			SMA_LKOH, SMA_LKOHi, SMA_LKOHName = getCandlesByIndex('SMA_LKOH', 0, 0, NumCandlesLKOH)
			SMA_ROSN, SMA_ROSNi, SMA_ROSNName = getCandlesByIndex('SMA_ROSN', 0, 0, NumCandlesROSN)
			SMADeltaLKOH = SMA_LKOH[SMA_LKOHi-1].close
			SMADeltaROSN = SMA_ROSN[SMA_ROSNi-1].close
			--разница средних цен активов
			SMADelta = SMADeltaROSN-SMADeltaLKOH
			--средняя разница активов минус текущая разница активов
			DifferenceSMADeltaNow = Delta-SMADelta
			message('РЦА: '..Delta..'\nSMA РЦА: '..SMADelta..'\nДельта: '..DifferenceSMADeltaNow)
			--message('Текущая дельта от средней SMA разницы активов:' ..DifferenceSMADeltaNow)

			constPlus = 150
			constMinus = -150

			if (DifferenceSMADeltaNow > constPlus) then	
			
				-- if time == 09:59 || 10:00 || 10:01 || 10:02 || 
				-- 23:47 || 23:48 || 23:49 || 23:50 { break; }

				local file_up = io.open("C:\\robot\\up.txt", 'r')
				local up = file_up:read "*n"
				file_up:close()
				
				local file_down = io.open("C:\\robot\\down.txt", 'r')
				local down = file_down:read "*n"
				file_down:close()
				
				-- message('case 1. up: '..up..' down: '..down)
				
				if (up == 1) then 
					-- zakrivaem ee
					-- shortim rosneft, longiruem lukoil
					shortROSNlongLKOH('1','1')
					
					-- pishem 0 v file sdelka up
					file = io.open("C:\\robot\\up.txt", 'w')
					file:write('0')
					file:close()		
					
					-- pishem '%date time% - zakrili sdelku up' v history
					local time = os.date('%x %X')
					file = io.open("C:\\robot\\history.txt", 'a')
					file:write(time..' закрыли UP-сделку\n')
					file:close()
					
					message ('zakryli UP-sdelku') 
					
					-- pause
					sleep(1*1000)
				end
				
				if (down == 0) then 
					
					-- otkryvaem ee
					-- shortim rosneft, longiruem lukoil
					shortROSNlongLKOH('1','1')
					
					-- pishem 1 v file sdelka down
					file = io.open("C:\\robot\\down.txt", 'w')
					file:write('1')
					file:close()
					
					-- pishem '%date-time% - otkryli sdelku down' v history
					local time = os.date('%x %X')
					file = io.open("C:\\robot\\history.txt", 'a')
					file:write(time..' открыли DOWN-сделку\n')
					file:close()
					
					message ('DOWN-sdelka ne naidena, ispravili')
					
					-- pause
					sleep(1*1000)
				end
				
				sleep(2*1000)

			elseif (DifferenceSMADeltaNow < constMinus) then
			
				-- if time == 09:59 || 10:00 || 10:01 || 10:02 || 
				-- 23:47 || 23:48 || 23:49 || 23:50 { break; }
				
				local file_up = io.open("C:\\robot\\up.txt", 'r')
				local up = file_up:read "*n"
				file_up:close()
				
				local file_down = io.open("C:\\robot\\down.txt", 'r')
				local down = file_down:read "*n"
				file_down:close()
				
				message('case 2. up: '..up..' down: '..down)
				
				if (down == 1) then 
					-- zakrivaem ee
					-- shortim lukoil, longiruem rosneft
					longROSNshortKOH('1','1')
					
					-- pishem 0 v file sdelka down
					file = io.open("C:\\robot\\down.txt", 'w')
					file:write('0')
					file:close()		
					
					-- pishem '%date time% - zakrili sdelku down' v history
					local time = os.date('%x %X')
					file = io.open("C:\\robot\\history.txt", 'a')
					file:write(time..' закрыли DOWN-сделку\n')
					file:close()
					
					message ('zakryli DOWN-sdelku') 
					
					-- pause
					sleep(1*1000)
				end
				
				if (up == 0) then 
					-- otkryvaem ee
					-- shortim lukoil, longiruem rosneft
					longROSNshortKOH('1','1')
					
					-- pishem 1 v file sdelka UP
					file = io.open("C:\\robot\\up.txt", 'w')
					file:write('1')
					file:close()
					
					-- pishem '%date-time% - otkryli sdelku up' v history
					local time = os.date('%x %X')
					file = io.open("C:\\robot\\history.txt", 'a')
					file:write(time..' открыли UP-сделку\n')
					file:close()
					
					message ('UP-sdelka ne naidena, ispravili')
					
					-- pause
					sleep(1*1000)
				end
				
				sleep(2*1000)

				else
				message ('Дельта вне диапазона принятия решения')
			end
			file = io.open("C:\\robot\\time.txt", "a")
			file:write(os.date("%x %X")..'\n')
			file:close()
			
			file = io.open("C:\\robot\\delta.txt", "a")
			file:write(DifferenceSMADeltaNow..'\n')
			file:close()
		end
	end
end