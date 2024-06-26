﻿
&Вместо("ПередЗаписью")
Процедура Расш1_ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	мСоздатьОповещениеОНовойЗадаче = Ложь;
	мСоздатьОповещениеОДобавленииКомментария = Ложь;
	
	Если НЕ Ссылка.Пустая() Тогда
		ИсходныеРеквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, 
			"Выполнена, ПометкаУдаления, СостояниеБизнесПроцесса");
	Иначе 
		ИсходныеРеквизиты = Новый Структура(
			"Выполнена, ПометкаУдаления, СостояниеБизнесПроцесса",
			Ложь, Ложь, Перечисления.СостоянияБизнесПроцессов.ПустаяСсылка());
	КонецЕсли;
	
	Если НЕ ИсходныеРеквизиты.Выполнена И Выполнена Тогда
		
		Если СостояниеБизнесПроцесса = Перечисления.СостоянияБизнесПроцессов.Остановлен Тогда
			ВызватьИсключение НСтр("ru = 'Нельзя выполнять задачи остановленных бизнес-процессов.'");
		КонецЕсли;	
		
		// Если задача выполнена, то запишем в реквизит Исполнитель того
		// пользователя, который фактически выполнил задачу. Это нам потом
		// потребуется для отчетов. Такую запись делаем только в том
		// случае, если в базе было не выполнено, а в объекте стало выполнено.
		Если НЕ ЗначениеЗаполнено(Исполнитель) Тогда
			Исполнитель = ПользователиКлиентСервер.АвторизованныйПользователь();
		КонецЕсли;
		Если ДатаИсполнения = Дата(1, 1, 1) Тогда
			ДатаИсполнения = ТекущаяДатаСеанса();
		КонецЕсли;
	КонецЕсли;
	
	Если Важность.Пустая() Тогда
		Важность = Перечисления.ВариантыВажностиЗадачи.Обычная;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СостояниеБизнесПроцесса) Тогда
		СостояниеБизнесПроцесса = Перечисления.СостоянияБизнесПроцессов.Активен;
	КонецЕсли;
	
	ПредметСтрокой = ОбщегоНазначения.ПредметСтрокой(Предмет);
	
// +CRM
	Если ЗначениеЗаполнено(ЭтотОбъект.БизнесПроцесс) Тогда
// -CRM
	Если ИсходныеРеквизиты.ПометкаУдаления <> ПометкаУдаления Тогда
		БизнесПроцессыИЗадачиСервер.ПриПометкеУдаленияЗадачи(Ссылка, ПометкаУдаления);
	КонецЕсли;
	
	Если НЕ Ссылка.Пустая() И ИсходныеРеквизиты.СостояниеБизнесПроцесса <> СостояниеБизнесПроцесса Тогда
		УстановитьСостояниеПодчиненныхБизнесПроцессов(СостояниеБизнесПроцесса);
	КонецЕсли;
// +CRM
	КонецЕсли;
// -CRM
	Если Выполнена И Не ПринятаКИсполнению Тогда
		ПринятаКИсполнению = Истина;
		ДатаПринятияКИсполнению = ТекущаяДатаСеанса();
	КонецЕсли;	
		
	// СтандартныеПодсистемы.УправлениеДоступом
	УстановитьПривилегированныйРежим(Истина); 
	Если ЗначениеЗаполнено(РольИсполнителя) 
		Или ЗначениеЗаполнено(ОсновнойОбъектАдресации)
	    Или ЗначениеЗаполнено(ДополнительныйОбъектАдресации) Тогда
		ГруппаИсполнителейЗадач = БизнесПроцессыИЗадачиСервер.ГруппаИсполнителейЗадач(РольИсполнителя, 
			ОсновнойОбъектАдресации, ДополнительныйОбъектАдресации);
	КонецЕсли;
	УстановитьПривилегированныйРежим(Ложь);
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
	// Заполнение реквизита ДатаПринятияКИсполнению.
	Если ПринятаКИсполнению И ДатаПринятияКИсполнению = Дата('00010101') Тогда
		ДатаПринятияКИсполнению = ТекущаяДатаСеанса();
	КонецЕсли;
	
	// +CRM
	Если ЗначениеЗаполнено(ЭтотОбъект.БизнесПроцесс) И ТипЗнч(ЭтотОбъект.БизнесПроцесс) = Тип("БизнесПроцессСсылка.CRM_БизнесПроцесс") Тогда
		Если мСостояниеСтрокой = Неопределено Тогда
			ОбновитьСостояниеСтрокой();
		Иначе
			CRM_СостояниеСтрокой = мСостояниеСтрокой;
		КонецЕсли;
		Если Ссылка.Пустая() И (ЗначениеЗаполнено(РольИсполнителя)
			ИЛИ (НЕ ЗначениеЗаполнено(РольИсполнителя) И НЕ Исполнитель = Пользователи.ТекущийПользователь())) Тогда
			мСоздатьОповещениеОНовойЗадаче = Истина;
		КонецЕсли;
	КонецЕсли;
	Если Выполнена Тогда
		CRM_ПроцентВыполненияЗадачи = 100;
	ИначеЕсли Ссылка.Выполнена И НЕ Выполнена Тогда
		CRM_ПроцентВыполненияЗадачи = 0;
	КонецЕсли;
	Если CRM_Личная И ЗначениеЗаполнено(CRM_Родитель) И НЕ ИсходныеРеквизиты.Выполнена И НЕ Выполнена И (CRM_ПроцентВыполненияЗадачи >= 100) Тогда
		Выполнена = Истина;
	КонецЕсли;
	ДополнительныеСвойства.Вставить("ПредыдущееЗначениеВыполнена", Ссылка.Выполнена);
	Если НЕ CRM_Личная И ЗначениеЗаполнено(CRM_Родитель) Тогда
		CRM_Родитель = Задачи.ЗадачаИсполнителя.ПустаяСсылка();
	КонецЕсли;
	// Эмуляция подписки на событие "УстановитьПометкуУдаленияПрисоединенныхФайловДокументы"
	ПрисоединенныеФайлы.УстановитьПометкуУдаленияПрисоединенныхФайловДокументов(ЭтотОбъект, Ложь, РежимЗаписиДокумента.Запись, РежимПроведенияДокумента.Неоперативный);
	// -CRM
	//УПДК+
	Если ЗначениеЗаполнено(БизнесПроцесс) 
		И ТипЗнч(БизнесПроцесс) = Тип("БизнесПроцессСсылка.CRM_БизнесПроцесс") 
		И ЗначениеЗаполнено(БизнесПроцесс.КартаМаршрута) Тогда
		
		ШаблонНаименованияЗадачи = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(БизнесПроцесс.КартаМаршрута, "ШаблонНаименованияЗадачи");
		Если Не ПустаяСтрока(ШаблонНаименованияЗадачи) Тогда
			Наименование = УПДК_БизнесПроцессыИЗадачи.НаименованиеПоШаблону(ШаблонНаименованияЗадачи, ЭтотОбъект);
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ Отказ И ЭтоНовый() И НЕ ЗначениеЗаполнено(ЭтотОбъект.CRM_НачалоПереадресации) Тогда
		
		УстановитьСсылкуНового(Задачи.ЗадачаИсполнителя.ПолучитьСсылку());
		
		НовСсылка = ПолучитьСсылкуНового();
		Задачи.ЗадачаИсполнителя.ЗаполнитьПодходящимиПредметами(ЭтотОбъект, НовСсылка);
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	CRM_ОбъектыПоБизнесПроцессам.Объект
		|ИЗ
		|	РегистрСведений.CRM_ОбъектыПоБизнесПроцессам КАК CRM_ОбъектыПоБизнесПроцессам
		|ГДЕ
		|	CRM_ОбъектыПоБизнесПроцессам.Задача = &Задача";
		
		Запрос.УстановитьПараметр("Задача", НовСсылка);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Если ЗначениеЗаполнено(РольИсполнителя) 
			И ВыборкаДетальныеЗаписи.Количество() = 1 
			И ВыборкаДетальныеЗаписи.Следующий() 
			И УПДК_БизнесПроцессыИЗадачи.ПолучитьДоступностьЗадачи(ЭтотОбъект, ВыборкаДетальныеЗаписи.Объект.Ответственный)Тогда
			
			Исполнитель = ВыборкаДетальныеЗаписи.Объект.Ответственный;
			РольИсполнителя = Неопределено;
			ПринятаКИсполнению = Истина;
			ДатаПринятияКИсполнению = ТекущаяДатаСеанса();
		
		КонецЕсли;	
		
	КонецЕсли;
	
	Если Не Отказ 
		И CRM_ТочкаМаршрута.УПДК_ПриниматьАвтоматически
		И УПДК_БизнесПроцессыИЗадачи.ПолучитьДоступностьЗадачи(ЭтотОбъект)
		И ЭтоНовый()
		Тогда 	
		
		Исполнитель = Пользователи.ТекущийПользователь();
		ПринятаКИсполнению = Истина;
		ДатаПринятияКИсполнению = ТекущаяДатаСеанса();		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(CRM_Партнер) И Не ЗначениеЗаполнено(КонтактноеЛицо) Тогда
		КонтактноеЛицо = CRM_Партнер.ОсновноеКонтактноеЛицо;
	КонецЕсли;
	
	ТекДата = ТекущаяДатаСеанса();
	ТекПользователь = Пользователи.ТекущийПользователь();
	Если ЗначениеЗаполнено(Ссылка) И Не Отказ Тогда	
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ЗадачаИсполнителя.Наименование КАК Наименование,
			|	ЗадачаИсполнителя.Выполнена КАК Выполнена,
			|	ЗадачаИсполнителя.Автор КАК Автор,
			|	ЗадачаИсполнителя.Важность КАК Важность,
			|	ЗадачаИсполнителя.ДатаНачала КАК ДатаНачала,
			|	ЗадачаИсполнителя.Описание КАК Описание,
			|	ЗадачаИсполнителя.СрокИсполнения КАК СрокИсполнения,
			|	ЗадачаИсполнителя.КрайнийСрок КАК КрайнийСрок,
			|	ЗадачаИсполнителя.Исполнитель КАК Исполнитель,
			|	ЗадачаИсполнителя.РольИсполнителя КАК РольИсполнителя,
			|	ЗадачаИсполнителя.Проекты.(
			|		Проект КАК Проект
			|	) КАК Проекты,
			|	ЗадачаИсполнителя.Подзадачи.(
			|		Задача КАК Задача
			|	) КАК Подзадачи,
			|	ЗадачаИсполнителя.СвязанныеЗадачи.(
			|		Задача КАК Задача
			|	) КАК СвязанныеЗадачи,
			|	ЗадачаИсполнителя.Наблюдатели.(
			|		Наблюдатель КАК Наблюдатель
			|	) КАК Наблюдатели,
			|	ЗадачаИсполнителя.Напоминания.(
			|		Адресат КАК Адресат,
			|		ДатаОповещения КАК ДатаОповещения,
			|		ИмяПоля КАК ИмяПоля,
			|		Канал КАК Канал,
			|		Отправлено КАК Отправлено,
			|		ОтправитьПочтой КАК ОтправитьПочтой,
			|		ОтправитьTelegram КАК ОтправитьTelegram,
			|		ОтправитьViber КАК ОтправитьViber,
			|		ОтправитьWhatsApp КАК ОтправитьWhatsApp
			|	) КАК Напоминания,
			|	ЗадачаИсполнителя.Отложена КАК Отложена,
			|	ЗадачаИсполнителя.АвтоЗавершатьЗадачуУсловие КАК АвтоЗавершатьЗадачуУсловие,
			|	ЗадачаИсполнителя.РазрешитьОтветственномуМенятьСрок КАК РазрешитьОтветственномуМенятьСрок,
			|	ЗадачаИсполнителя.ПропускатьВыходные КАК ПропускатьВыходные,
			|	ЗадачаИсполнителя.Проверяющий КАК Проверяющий,
			|	ЗадачаИсполнителя.ДатаПроверки КАК ДатаПроверки,
			|	ЗадачаИсполнителя.РезультатВыполнения КАК РезультатВыполнения
			|ИЗ
			|	Задача.ЗадачаИсполнителя КАК ЗадачаИсполнителя
			|ГДЕ
			|	ЗадачаИсполнителя.Ссылка = &Ссылка";
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		ТЗ_Задачи = Запрос.Выполнить().Выгрузить();
		СтарыеДанные = ТЗ_Задачи[0];
		
		Набор = РегистрыСведений.Дев_ИсторияЗадач.СоздатьНаборЗаписей();
		Набор.Отбор.Задача.Установить(Ссылка);
		Набор.Прочитать();  
		СтрокВНаборе = Набор.Количество();
		
		ЗаписалиПроверяющего = Ложь;
		
		Для каждого ТекРеквизит Из ТЗ_Задачи.Колонки Цикл
			Сч = Новый УникальныйИдентификатор();
			Если ТекРеквизит.Имя = "Проекты" Тогда
				ИсторияПоТЧ("Проекты", "Проекты", "Проект", Набор, СтарыеДанные, ЭтотОбъект, ТекПользователь, ТекДата, Ссылка); 
			ИначеЕсли ТекРеквизит.Имя = "Подзадачи" Тогда
				ИсторияПоТЧ("Подзадачи", "Подзадачи", "Задача", Набор, СтарыеДанные, ЭтотОбъект, ТекПользователь, ТекДата, Ссылка);
			ИначеЕсли ТекРеквизит.Имя = "СвязанныеЗадачи" Тогда
				ИсторияПоТЧ("СвязанныеЗадачи", "Связанные задачи", "Задача", Набор, СтарыеДанные, ЭтотОбъект, ТекПользователь, ТекДата, Ссылка);
			ИначеЕсли ТекРеквизит.Имя = "Наблюдатели" Тогда
				ИсторияПоТЧ("Наблюдатели", "Наблюдатели", "Наблюдатель", Набор, СтарыеДанные, ЭтотОбъект, ТекПользователь, ТекДата, Ссылка);
			ИначеЕсли ТекРеквизит.Имя = "Напоминания" Тогда
				ИсторияПоТЧ("СвязанныеЗадачи", "Связанные задачи", "Задача", Набор, СтарыеДанные, ЭтотОбъект, ТекПользователь, ТекДата, Ссылка);
				Удалены = "";
				Для каждого ТекСтр Из СтарыеДанные[ТекРеквизит.Имя] Цикл
					НайденныеСтроки = ЭтотОбъект[ТекРеквизит.Имя].НайтиСтроки(
						Новый Структура("Адресат,ДатаОповещения,ИмяПоля,Канал,ОтправитьПочтой,ОтправитьTelegram,ОтправитьViber,ОтправитьWhatsApp",
						ТекСтр.Адресат, ТекСтр.ДатаОповещения, ТекСтр.ИмяПоля, ТекСтр.Канал, ТекСтр.ОтправитьПочтой, 
						ТекСтр.ОтправитьTelegram, ТекСтр.ОтправитьViber, ТекСтр.ОтправитьWhatsApp));
					Если НайденныеСтроки.Количество() = 0 Тогда
						Удалены = Удалены + Строка(ТекСтр.ДатаОповещения) + " " + ТекСтр.ИмяПоля + ",";
					КонецЕсли;				
				КонецЦикла;
				Если Удалены <> "" Тогда
					Удалены = Лев(Удалены, СтрДлина(Удалены) - 1);
					Менеджер = Набор.Добавить();
					Менеджер.Период = ТекДата;
					Менеджер.Задача = Ссылка;
					Менеджер.Реквизит = СтрШаблон("%1 (%2)",ТекРеквизит.Имя, Сч);
					Менеджер.Ответственный = ТекПользователь; 					
					Менеджер.Описание = "Удалены напоминания: " + Удалены;	
				КонецЕсли;
				Добавлены = "";
				Для каждого ТекСтр Из ЭтотОбъект[ТекРеквизит.Имя] Цикл
					НайденныеСтроки = СтарыеДанные[ТекРеквизит.Имя].НайтиСтроки(
						Новый Структура("Адресат,ДатаОповещения,ИмяПоля,Канал,ОтправитьПочтой,ОтправитьTelegram,ОтправитьViber,ОтправитьWhatsApp",
						ТекСтр.Адресат, ТекСтр.ДатаОповещения, ТекСтр.ИмяПоля, ТекСтр.Канал, ТекСтр.ОтправитьПочтой, 
						ТекСтр.ОтправитьTelegram, ТекСтр.ОтправитьViber, ТекСтр.ОтправитьWhatsApp));
					Если НайденныеСтроки.Количество() = 0 Тогда
						Добавлены = Добавлены + Строка(ТекСтр.ДатаОповещения) + " " + ТекСтр.ИмяПоля + ",";
					КонецЕсли;				
				КонецЦикла;
				Если Добавлены <> "" Тогда
					Добавлены = Лев(Добавлены, СтрДлина(Добавлены) - 1);
					Менеджер = Набор.Добавить();
					Менеджер.Период = ТекДата;
					Менеджер.Задача = Ссылка;
					Менеджер.Реквизит = СтрШаблон("%1 (%2)",ТекРеквизит.Имя, Сч);
					Менеджер.Ответственный = ТекПользователь; 					
					Менеджер.Описание = "Добавлены напоминания: " + Добавлены;	
				КонецЕсли;

			ИначеЕсли СтарыеДанные[ТекРеквизит.Имя] <> ЭтотОбъект[ТекРеквизит.Имя] Тогда
				Менеджер = Набор.Добавить();
				Менеджер.Период = ТекДата;
				Менеджер.Задача = Ссылка;
				Менеджер.Реквизит = СтрШаблон("%1 (%2)",ТекРеквизит.Заголовок, Сч);
		        Менеджер.СтароеЗначение = СтарыеДанные[ТекРеквизит.Имя];
				Менеджер.НовоеЗначение = ЭтотОбъект[ТекРеквизит.Имя];
				Менеджер.Ответственный = ТекПользователь;     
				Если ТекРеквизит.Имя = "Наименование" Тогда
				    Менеджер.Описание = "Тема: " + ЭтотОбъект[ТекРеквизит.Имя];
				ИначеЕсли ТекРеквизит.Имя = "Выполнена" Тогда
				    Менеджер.Описание = "Задача " + ?(ЭтотОбъект[ТекРеквизит.Имя], "", "не") + " выполнена";
				ИначеЕсли ТекРеквизит.Имя = "Автор" 
					Или ТекРеквизит.Имя = "Важность"  
					Или ТекРеквизит.Имя = "Описание" 
					Или ТекРеквизит.Имя = "Исполнитель" Тогда
				    Менеджер.Описание = ТекРеквизит.Имя + ": " + Строка(ЭтотОбъект[ТекРеквизит.Имя]);
				ИначеЕсли ТекРеквизит.Имя = "ДатаНачала" Тогда
				    Менеджер.Описание = "Начать задачу: " + Строка(ЭтотОбъект[ТекРеквизит.Имя]);
				ИначеЕсли ТекРеквизит.Имя = "ДатаНачала" Тогда
				    Менеджер.Описание = "Начать задачу: " + Строка(ЭтотОбъект[ТекРеквизит.Имя]);
				ИначеЕсли ТекРеквизит.Имя = "СрокИсполнения" Тогда
				    Менеджер.Описание = "Закончить задачу: " + Строка(ЭтотОбъект[ТекРеквизит.Имя]);				
				ИначеЕсли ТекРеквизит.Имя = "КрайнийСрок" Тогда
				    Менеджер.Описание = "Крайний срок: " + Строка(ЭтотОбъект[ТекРеквизит.Имя]);
				ИначеЕсли ТекРеквизит.Имя = "РольИсполнителя" Тогда
				    Менеджер.Описание = "Исполнитель: " + Строка(ЭтотОбъект[ТекРеквизит.Имя]);
				ИначеЕсли ТекРеквизит.Имя = "Отложена" И ЭтотОбъект[ТекРеквизит.Имя] Тогда
				    Менеджер.Описание = "Задача отложена";
				ИначеЕсли ТекРеквизит.Имя = "Отложена" И Не ЭтотОбъект[ТекРеквизит.Имя] Тогда
				    Менеджер.Описание = "Задача возвращена в работу";
				ИначеЕсли ТекРеквизит.Имя = "АвтоЗавершатьЗадачуУсловие" И ЭтотОбъект[ТекРеквизит.Имя] Тогда
				    Менеджер.Описание = "Автоматически завершать задачу при завершении подзадач";
				ИначеЕсли ТекРеквизит.Имя = "РазрешитьОтветственномуМенятьСрок" И ЭтотОбъект[ТекРеквизит.Имя] Тогда
				    Менеджер.Описание = "Разрешить ответственному менять срок выполнения задачи";
				ИначеЕсли ТекРеквизит.Имя = "ПропускатьВыходные" И ЭтотОбъект[ТекРеквизит.Имя] Тогда
				    Менеджер.Описание = "Пропустить выходные и праздничные дни";
				ИначеЕсли ТекРеквизит.Имя = "Проверяющий" Или ТекРеквизит.Имя = "ДатаПроверки" И Не ЗаписалиПроверяющего Тогда
					ЗаписалиПроверяющего = Истина;
					Менеджер.Описание = "Проверить работу после завершения задачи: " + Строка(ЭтотОбъект["Проверяющий"]) + " " + Строка(ЭтотОбъект["ДатаПроверки"]);
				ИначеЕсли ТекРеквизит.Имя = "РезультатВыполнения" Тогда
					Менеджер.Описание = "Комментарий: " + Строка(ЭтотОбъект[ТекРеквизит.Имя]);
					мСоздатьОповещениеОДобавленииКомментария = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		Если СтрокВНаборе <> Набор.Количество() Тогда
			Набор.Записать(Истина);
		КонецЕсли;		
	КонецЕсли;

КонецПроцедуры
