﻿
// Запускает команду на выполнение
//
Процедура ЗапуститьКоманду(Команда)
	
	ПоследняяКоманда = Команда;
	
	#Если Клиент Тогда
	
	Если ЭтоLinux()	Тогда
		КомандаСистемы(Команда);
	Иначе
		Попытка
			Shell = Новый COMОбъект("WScript.Shell");
			Shell.Run("cmd /c " + СтрЗаменить(Команда, "\", "\\"), 0, Истина);
		Исключение
			КомандаСистемы(Команда);
		КонецПопытки;
	КонецЕсли;
	
	#КонецЕсли
	
КонецПроцедуры

// Возвращает информацию о последней ошибке
// 
Функция ПоследняяОшибка() Экспорт
	
	Возврат ОписаниеОшибки + Символы.ПС + ПоследняяКоманда;
	
КонецФункции

// Объединяет два массива в один
//
// Параметры:
//  Приемник (Массив) - Массив приемник
//  Источник (Массив) - Массив источник
//
// Возвращаемое значение:
//  Массив - Результат объединения
//
Процедура ОбъединитьМассивы(Приемник, Источник)
	
	Для Каждого Значение ИЗ Источник Цикл
		Приемник.Добавить(Значение);		
	КонецЦикла;
	Источник = Неопределено;
	
КонецПроцедуры

// Определяет, относится текущая ОС к linux
//
// Возвращаемое значение:
//  Булево
//
Функция ЭтоLinux()
	
	СистемнаяИнформация = Новый СистемнаяИнформация();

	Возврат (0 < Найти(Строка(СистемнаяИнформация.ТипПлатформы), "Linux"));
	
КонецФункции

// Возвращает разделитель пути в зависимости от ОС
//
Функция РазделительПути()
	
	СистемнаяИнформация = Новый СистемнаяИнформация();
	Возврат ?(ЭтоLinux(), "/", "\");
	
КонецФункции

// Возвращает путь к каталогу Poppler, если он задан
//
Функция ПолучитьКаталогPopler()
	
	Каталог = КаталогPoppler;
	
	Если ЗначениеЗаполнено(Каталог) Тогда
		
		СистемнаяИнформация = Новый СистемнаяИнформация();
	
		Разделитель = РазделительПути();
			
		Если Прав(Каталог, 1) <> Разделитель Тогда
			Каталог = Каталог + Разделитель;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Каталог;
	
КонецФункции

// Сохраняет текст ошибки и возвращает Неопределено
//
// Параметры:
//  ТекстОшибки (Строка) - Текст возникшей ошибки
//
// Возвращаемое значение:
//	Неопределено
//
Функция Ошибка(ТекстОшибки)
	
	ОписаниеОшибки = ТекстОшибки;
	Возврат Неопределено;
	
КонецФункции

// Возвращает информацию о PDF-файле в виде соотвествия Параметр-Значение
//
// Параметры:
//  ПутьКФайлу (Строка) - Файл, информацию о котором необходимо получить
//
// Возвращаемое значение:
//  Соответствие - Сооответствие, где ключ - имя параметра
//	Неопределено - в случае ошибки
//
Функция ИнформацияОФайле(ПутьКФайлу) Экспорт
	
	ФайлНаДиске = Новый Файл(ПутьКФайлу);
	
	Если ФайлНаДиске.Существует() Тогда
	
		Вывод = ПолучитьИмяВременногоФайла("txt");
		
		Обработчик = ПолучитьКаталогPopler() + "pdfinfo";
		Команда = Обработчик + " """ + ПутьКФайлу + """ > """ + Вывод + """";
			
		ЗапуститьКоманду(Команда);
		
		ФайлНаДиске = Новый Файл(Вывод);
		
		Если ФайлНаДиске.Существует() Тогда
			
			Информация = Новый Соответствие();
			
			Файл = Новый ЧтениеТекста(Вывод);
			
			Стр = Файл.ПрочитатьСтроку();
			
			Пока Стр <> Неопределено Цикл
				
				Подстроки = СтрЗаменить(Стр, ":", Символы.ПС);			
				Параметр = СокрЛП(СтрПолучитьСтроку(Подстроки, 1));
				Значение = СокрЛП(СтрПолучитьСтроку(Подстроки, 2));
				
				Информация.Вставить(Параметр, Значение);
				
				Стр = Файл.ПрочитатьСтроку();
				
			КонецЦикла;
			
			Файл.Закрыть();
			
			УдалитьФайлы(Вывод);
			
			Возврат Информация;
			
		Иначе
			
			Возврат Ошибка("Не удалось получить информацию о файле");
			
		КонецЕсли;
		
	Иначе
		
		Возврат Ошибка("Файл """ + ПутьКФайлу+ """ отсутствует");
		
	КонецЕсли;
	
КонецФункции

// Возвращает информацию о PDF-файле в виде строки
//
// Параметры:
//  ПутьКФайлу (Строка) - Файл, информацию о котором необходимо получить
//
// Возвращаемое значение:
//  Строка - Строка, содержащая всю информацию о файле
//	Неопределено - в случае ошибки
//
Функция СтрокаИнформацииОФайле(ПутьКФайлу) Экспорт
	
	Информация = ИнформацияОФайле(ПутьКФайлу);
	
	Если Информация <> Неопределено Тогда
		
		Строка = "";
		
		Для Каждого Обход ИЗ Информация Цикл
			
			Если ЗначениеЗаполнено(Строка) Тогда
				Строка = Строка + Символы.ПС;
			КонецЕсли;
			
			Строка = Строка + Обход.Ключ + ": " + Обход.Значение;
			
		КонецЦикла;
		
		Возврат Строка;
		
	Иначе
		
		Возврат Неопределено;
		
	КонецЕсли;
			
КонецФункции

// Возвращает информацию о количестве страниц PDF-файла.
//
// Параметры:
//  ПутьКФайлу (Строка) - Файл, количество страниц которого требуется получить 
//
// Возвращаемое значение:
//   Число - число страниц файла
//
Функция ПолучитьКоличествоСтраниц(ПутьКФайлу) Экспорт
	
	Информация = ИнформацияОФайле(ПутьКФайлу);
	
	Если Информация <> Неопределено Тогда
		
		Попытка
			Возврат Число(Информация.Получить("Pages"));
		Исключение
			Возврат Ошибка("В информации о файле нет данных о количестве страниц");
		КонецПопытки;
		
	Иначе
		
		Возврат Ошибка("Указаны некорректные номера страниц");
		
	КонецЕсли;
	
КонецФункции

// Возвращает массив изображений страниц PDF-файла.
//
// Параметры:
//  ПутьКФайлу (Строка) - Файл, из котого требуется получить страницы в виде изображений 
//  DPI (Число) - Качество изображений в DPI (по умолчанию 200 DPI).
//  ПерваяСтраница (Число) - Номер первой извлекаемой страницы
//  ПоследняяСтраница (Число) - Номер последней извлекаемой страницы
//  Формат (Строка) - формат изображения (по умолчанию jpeg)
//		Возможные значения:
//	 		- "jpeg"
//	 		- "png"
//	 		- "tiff"
//  ЧерноБелый (Булево) - получение изображений в черно-белом формате (оттенки серого) 
//
// Возвращаемое значение:
//  Массив[Структура(НомерСтраницы, ДвоичныеДанные, Размер, Ошибка)] - массив с изображениями, 
//		где
//			НомерСтраницы (Число) - номер страницы, изображение которой получено
//			ДвоичныеДанные (ДвоичныеДанные) - данные изображения
//			Размер (Число) - размер изображения в байтах
//			Ошибка (Булево) - признак того, что при получении этой страницы произошла ошибка
//	Неопределено - в случае ошибки
//
Функция ФайлВИзображения(ПутьКФайлу, DPI = 200, ПерваяСтраница = 0, ПоследняяСтраница = 0, Формат = "jpeg", ЧерноБелый = Ложь) Экспорт
	
	ФайлНаДиске = Новый Файл(ПутьКФайлу);
	
	Если ФайлНаДиске.Существует() Тогда
	
		Если ПерваяСтраница = 0 Тогда
			ПерваяСтраница = 1;
		КонецЕсли;
		
		Если ПоследняяСтраница = 0 Тогда
			ПоследняяСтраница = ПолучитьКоличествоСтраниц(ПутьКФайлу);
		КонецЕсли;
		
		Если ПоследняяСтраница = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
			
		Если ПоследняяСтраница < ПерваяСтраница ИЛИ ПерваяСтраница <= 0 Тогда
			Возврат Ошибка("Указаны некорректные номера страниц");
		КонецЕсли;	
		                                         
		Обработчик = ПолучитьКаталогPopler() + "pdftoppm";
		
		Изображения = Новый Массив();
		ЕстьДанные = Ложь;
		
		Для НомерСтраницы = ПерваяСтраница По ПоследняяСтраница Цикл
			
			Параметры = " """ + ПутьКФайлу + """ -r " + Формат(DPI, "ЧГ=0");
			Параметры = Параметры + " -f " + Формат(НомерСтраницы, "ЧГ=0");
			Параметры = Параметры + " -l " + Формат(НомерСтраницы, "ЧГ=0");
			Параметры = Параметры + " -" + Формат;	
					
			Если ЧерноБелый Тогда
				Параметры = Параметры + " -gray";
			КонецЕсли;
					
			Вывод = ПолучитьИмяВременногоФайла(Формат);
			
			Параметры = Параметры + " > """ + Вывод + """";
			
			Команда = Обработчик + Параметры; 
			
			ЗапуститьКоманду(Команда);
			
			ФайлНаДиске = Новый Файл(Вывод);
			
			Если ФайлНаДиске.Существует() И 0 < ФайлНаДиске.Размер() Тогда
				Изображения.Добавить(Новый Структура("НомерСтраницы, ДвоичныеДанные, Размер, Ошибка", НомерСтраницы, Новый ДвоичныеДанные(Вывод), ФайлНаДиске.Размер(), Ложь));
				ЕстьДанные = Истина;
			Иначе
				Изображения.Добавить(Новый Структура("НомерСтраницы, ДвоичныеДанные, Размер, Ошибка", НомерСтраницы, Неопределено, 0, Истина));
				Ошибка("Не удалось сохранить страницу файла");
			КонецЕсли;
						
			УдалитьФайлы(Вывод);
			
		КонецЦикла;
		
		Если ЕстьДанные Тогда
			Возврат Изображения;
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		
	Иначе
		
		Возврат Ошибка("Файл """ + ПутьКФайлу+ """ отсутствует");
		
	КонецЕсли;
	
КонецФункции

// Возвращает массив c текстом каждой страницы PDF-файла
//
// Параметры:
//  ПутьКФайлу (Строка) - Файл, из котого требуется получить текст
//  ПерваяСтраница (Число) - Номер первой извлекаемой страницы
//  ПоследняяСтраница (Число) - Номер последней извлекаемой страницы
//
// Возвращаемое значение:
//  Массив[Структура(НомерСтраницы, Текст, Ошибка)] - массив с текстом каждой странице,
//		где
//			НомерСтраницы (Число) - номер страницы, с которой получен текст
//			Текст (Строка) - сам текст
//			Ошибка (Булево) - признак того, что при получении этой страницы произошла ошибка
//	Неопределено - в случае ошибки
//
Функция ФайлВТекст(ПутьКФайлу, ПерваяСтраница = 0, ПоследняяСтраница = 0) Экспорт
	
	ФайлНаДиске = Новый Файл(ПутьКФайлу);
	
	Если ФайлНаДиске.Существует() Тогда
	
		Если ПерваяСтраница = 0 Тогда
			ПерваяСтраница = 1;
		КонецЕсли;
		
		Если ПоследняяСтраница = 0 Тогда
			ПоследняяСтраница = ПолучитьКоличествоСтраниц(ПутьКФайлу);
		КонецЕсли;
		
		Если ПоследняяСтраница = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
			
		Если ПоследняяСтраница < ПерваяСтраница ИЛИ ПерваяСтраница <= 0 Тогда
			Возврат Ошибка("Указаны некорректные номера страниц");
		КонецЕсли;	
		                                         
		Обработчик = ПолучитьКаталогPopler() + "pdftotext";
		
		Страницы = Новый Массив();
		ЕстьДанные = Ложь;
		
		Для НомерСтраницы = ПерваяСтраница По ПоследняяСтраница Цикл
			
			Параметры = " """ + ПутьКФайлу + """";;
			Параметры = Параметры + " -f " + Формат(НомерСтраницы, "ЧГ=0");
			Параметры = Параметры + " -l " + Формат(НомерСтраницы, "ЧГ=0");
						
			Вывод = ПолучитьИмяВременногоФайла("txt");
			
			Параметры = Параметры + " """ + Вывод + """";
			
			Команда = Обработчик + Параметры; 
			
			ЗапуститьКоманду(Команда);
			
			ФайлНаДиске = Новый Файл(Вывод);
			
			Если ФайлНаДиске.Существует() И 0 < ФайлНаДиске.Размер() Тогда
				Файл = Новый ТекстовыйДокумент();
				Файл.Прочитать(Вывод, КодировкаТекста.UTF8);		
				Страницы.Добавить(Новый Структура("НомерСтраницы, Текст, Ошибка", НомерСтраницы, Файл.ПолучитьТекст(), Ложь));
				ЕстьДанные = Истина;
			Иначе
				Страницы.Добавить(Новый Структура("НомерСтраницы, Текст, Ошибка", НомерСтраницы, "", Истина));
				Ошибка("Не удалось прочитать страницу файла");
			КонецЕсли;
			
			УдалитьФайлы(Вывод);
			
		КонецЦикла;
		
		Если ЕстьДанные Тогда
			Возврат Страницы;
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		
	Иначе
		
		Возврат Ошибка("Файл """ + ПутьКФайлу+ """ отсутствует");
		
	КонецЕсли;
	
КонецФункции

// Возвращает массив изображений, которые содержаться в PDF-файле.
//
// Параметры:
//  ПутьКФайлу (Строка) - Файл, из котого требуется получить страницы в виде изображений 
//  ПерваяСтраница (Число) - Номер первой извлекаемой страницы
//  ПоследняяСтраница (Число) - Номер последней извлекаемой страницы
//
// Возвращаемое значение:
//  Массив[Структура(НомерСтраницы, НомерИзображения, Расширение, Размер, ДвоичныеДанные)] - массив изображений,
//		где
//			НомерСтраницы (Число) - номер страницы, на которой находилось изображение
//			НомерИзображения (Число) - порядковый номер изображения на странице
//			ДвоичныеДанные (ДвоичныеДанные) - данные изображения
//			Расширение (Строка) - расширение файла изображения
//			Размер (Число) - размер изображения в байтах
//	Неопределено - в случае ошибки
//
Функция ИзображенияИзФайла(ПутьКФайлу, ПерваяСтраница = 0, ПоследняяСтраница = 0) Экспорт
	
	ФайлНаДиске = Новый Файл(ПутьКФайлу);
	
	Если ФайлНаДиске.Существует() Тогда
	
		Если ПерваяСтраница = 0 Тогда
			ПерваяСтраница = 1;
		КонецЕсли;
		
		Если ПоследняяСтраница = 0 Тогда
			ПоследняяСтраница = ПолучитьКоличествоСтраниц(ПутьКФайлу);
		КонецЕсли;
		
		Если ПоследняяСтраница = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
			
		Если ПоследняяСтраница < ПерваяСтраница ИЛИ ПерваяСтраница <= 0 Тогда
			Возврат Ошибка("Указаны некорректные номера страниц");
		КонецЕсли;	
		
		ВремКаталог = КаталогВременныхФайлов() + "popler_tmp_img\";
		СоздатьКаталог(ВремКаталог);
		
		Обработчик = ПолучитьКаталогPopler() + "pdfimages";
		
		Параметры = " """ + ПутьКФайлу + """ -all -p";
		Параметры = Параметры + " -f " + Формат(ПерваяСтраница, "ЧГ=0");
		Параметры = Параметры + " -l " + Формат(ПоследняяСтраница, "ЧГ=0");		
		Параметры = Параметры + " " + ВремКаталог;		
		
		Изображения = Новый Массив();
		
		Команда = Обработчик + Параметры; 
		
		ЗапуститьКоманду(Команда);
		
		Файлы = НайтиФайлы(ВремКаталог, "*.jpg");	
		ОбъединитьМассивы(Файлы, НайтиФайлы(ВремКаталог, "*.png"));
		ОбъединитьМассивы(Файлы, НайтиФайлы(ВремКаталог, "*.tif"));
			
		Для Каждого Файл ИЗ Файлы Цикл
			
			Если 0 < Файл.Размер() Тогда
				
				Подстроки = СтрЗаменить(Файл.ИмяБезРасширения, "-", Символы.ПС);
				
				НомерСтраницы = СтрПолучитьСтроку(Подстроки, 2);
				НомерИзображения = СтрПолучитьСтроку(Подстроки, 3);
				
				Изображения.Добавить(Новый Структура("НомерСтраницы, НомерИзображения, Расширение, Размер, ДвоичныеДанные", НомерСтраницы, НомерИзображения, Файл.Расширение, Файл.Размер(), Новый ДвоичныеДанные(Файл.ПолноеИмя)));
				
				УдалитьФайлы(Файл.ПолноеИмя);
				
			КонецЕсли;
			
		КонецЦикла;
				
		УдалитьФайлы(ВремКаталог);
				
		Возврат Изображения;
		
	Иначе
		
		Возврат Ошибка("Файл """ + ПутьКФайлу+ """ отсутствует");
		
	КонецЕсли;
	
КонецФункции

// Разбивает PDF-файл на отдельные файлы
//
// Параметры:
//  ПутьКФайлу (Строка) - Файл, который требуется разбить
//  Каталог (Строка) - Каталог, в котором необходимо создать отдельные файлы
//	 В случает отсутствия каталог создается. Если каталог не указан,
//	 файлы сохраняются в каталоге временных файлов
//  ПерваяСтраница (Число) - Номер первой извлекаемой страницы
//  ПоследняяСтраница (Число) - Номер последней извлекаемой страницы
//
// Возвращаемое значение:
//  Массив[Файл] - Массив полученных файлов
//	Неопределено - в случае ошибки
//
Функция РазбитьФайл(ПутьКФайлу, Каталог = Неопределено, ПерваяСтраница = 0, ПоследняяСтраница = 0) Экспорт
	
	ФайлНаДиске = Новый Файл(ПутьКФайлу);
	
	Если ФайлНаДиске.Существует() Тогда
	
		Если ПерваяСтраница = 0 Тогда
			ПерваяСтраница = 1;
		КонецЕсли;
		
		Если ПоследняяСтраница = 0 Тогда
			ПоследняяСтраница = ПолучитьКоличествоСтраниц(ПутьКФайлу);
		КонецЕсли;
		
		Если ПоследняяСтраница = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
			
		Если ПоследняяСтраница < ПерваяСтраница ИЛИ ПерваяСтраница <= 0 Тогда
			Возврат Ошибка("Указаны некорректные номера страниц");
		КонецЕсли;	
			
		КаталогРезультата = Каталог;
		
		Если ЗначениеЗаполнено(КаталогРезультата) Тогда
			Попытка
				СоздатьКаталог(КаталогРезультата);
			Исключение
				Возврат Ошибка("Не удалось создать каталог """ + КаталогРезультата + """ для сохранения файлов");
			КонецПопытки;
		Иначе
			КаталогРезультата = КаталогВременныхФайлов();
		КонецЕсли;
		
		Разделитель = РазделительПути();
				
		Если Прав(КаталогРезультата, 1) <> Разделитель Тогда
			КаталогРезультата = КаталогРезультата + Разделитель;
		КонецЕсли;
			
		Обработчик = ПолучитьКаталогPopler() + "pdfseparate";
			
		Параметры = " """ + ПутьКФайлу + """";
		Параметры = Параметры + " -f " + Формат(ПерваяСтраница, "ЧГ=0");
		Параметры = Параметры + " -l " + Формат(ПоследняяСтраница, "ЧГ=0");		
		Параметры = Параметры + " " + КаталогРезультата + ФайлНаДиске.ИмяБезРасширения + "_%d.pdf";
		
		Файлы = Новый Массив();
		
		Команда = Обработчик + Параметры; 
		
		ЗапуститьКоманду(Команда);
		
		Возврат НайтиФайлы(КаталогРезультата, ФайлНаДиске.ИмяБезРасширения + "_*.pdf");
		
	Иначе
		
		Возврат Ошибка("Файл """ + ПутьКФайлу+ """ отсутствует");
		
	КонецЕсли;
	
КонецФункции

// Разбивает PDF-файл на отдельные файлы
//
// Параметры:
//  МассивФайлов (Массив[Строка]) - Массив файлов, которые необходимо объединить в один
//  ВыходнойФайл (Строка) - Файл, в который необходимо сохранить результат.
//	 Если файл не указан, то объединенный файл создается в каталоге временных файлов.
//
// Возвращаемое значение:
//  Строка - имя созданного файла в случае успешного объединения
//	Неопределено - в случае ошибки
//
Функция ОбъединитьНесколькоФайлов(МассивФайлов, ВыходнойФайл = Неопределено) Экспорт
		
	Если ТипЗнч(МассивФайлов) = Тип("Массив") И 0 < МассивФайлов.Количество() Тогда
	
		РезультирующийФайл = ВыходнойФайл;
		
		Если НЕ ЗначениеЗаполнено(РезультирующийФайл) Тогда
			РезультирующийФайл = ПолучитьИмяВременногоФайла("pdf");
		КонецЕсли;
		
		Обработчик = ПолучитьКаталогPopler() + "pdfunite";
		
		Параметры = " ";
		
		Для Каждого ИмяФайла ИЗ МассивФайлов Цикл
			Параметры = Параметры + """" + ИмяФайла + """ ";
		КонецЦикла;
		
		Команда = Обработчик + Параметры + РезультирующийФайл; 
		
		ЗапуститьКоманду(Команда);
			
		ФайлНаДиске = Новый Файл(РезультирующийФайл);
		
		Если ФайлНаДиске.Существует() Тогда
			Возврат РезультирующийФайл;
		Иначе
			Возврат Ошибка("Не удалось объединить файлы");
		КонецЕсли;
		
	Иначе
		
		Возврат Ошибка("Не указаны файлы для объединения или некорректное значение параметра");
		
	КонецЕсли;
	
КонецФункции

