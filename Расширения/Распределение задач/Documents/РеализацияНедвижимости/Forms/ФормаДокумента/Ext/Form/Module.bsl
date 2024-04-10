﻿
&НаСервере
Процедура Расш1_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	Если Не Пользователи.РолиДоступны("ПолныйПрава") Тогда
		Если Не Объект.Ссылка.Пустая() Тогда
			Если ЗначениеЗаполнено(Объект.Брокер) Тогда
				Элементы.Брокер.Доступность = УПДК_БизнесПроцессыИЗадачиПовтИсп.ВозможностьМенятьБрокераВДоговоре(Объект.Ссылка);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура Расш1_ПослеЗаписиНаСервереПосле(ТекущийОбъект, ПараметрыЗаписи)
	
	Если Объект.Статус = Перечисления.СтатусыДоговоровСПокупателями.НаПодписании
		И УПДК_БизнесПроцессыИЗадачиПовтИсп.РаспределениеЗадачВключено()
		И УПДК_БизнесПроцессыИЗадачиПовтИсп.ВозможностьМенятьБрокераВДоговоре(Объект.Ссылка) Тогда
		Брокер = УПДК_БизнесПроцессыИЗадачиПовтИсп.ПрикрепленныйБрокер(Объект.Ссылка);
		ТекущийБрокер = Объект.брокер;
		Если Не Брокер = ТекущийБрокер Тогда
			СтруктураЗаполнения = Новый Структура("Брокер", Брокер);
			УПДК_ОбщегоНазначения.ЗаписатьДанныеВОбъектСБлокировкой(Объект.Ссылка, СтруктураЗаполнения);
		КонецЕсли;
	КонецЕсли;
	 
КонецПроцедуры 

