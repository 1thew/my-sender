# my-sender
Automatically exported from code.google.com/p/my-sender


SMS Sender
Программа для отправки SMS, написана на delphi/lazarus. Была разработана мной во времена работы в холдинге "Алтайские закрома". Была написана за 1 рабочий день. 
Оригинальная идея и часть кода взяты с просторов хабра.

- программа использует подключенный GSM-модем (свисток), подключается к COM-порту для отправки/получения SMS. Кстати, работает не со всеми GSM-чипами - разные инструкции для управления COM
- в программе реализован не сильно сложный механизм UniqueID для ПК - планировал продавать ключи к программе, залочив на конкертный ПК, но СЕЙЧАС это не сильно актуально.
- этот комментарий оставлю для тех, кто ХОЧЕТ "ЧТО ТО ИЗ НАКОДЕННОГО" ПОСМОТРЕТЬ НА ГИТХАБЕ. Смотрите, мне не жалко :)
- кстати, она вешается на http-порт, и может формировать sms из отправленного(в неё) http-get запроса. Таким образом 1С отсылала свои сообщения.
