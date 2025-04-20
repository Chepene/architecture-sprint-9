workspace "Ecosys" {

    !identifiers hierarchical

    model {
        
        properties {
            "structurizr.groupSeparator" "/"
        }
    
        guest = person "Гость"
        
        client = person "Клиент"
        
        front_office = person "Сотрудник фронт-офиса"
        
        back_office_deposits = person "Сотрудник бэк-офиса (депозиты)"
        
        back_office_credits = person "Сотрудник бэк-офиса (кредиты)"
        
        call_center_employee = person "Сотрудник колл-центра"

        event_topic = softwareSystem "event-topic" "[Kafka]" {
            tags "Queue"
        }
        
        sms_topic = softwareSystem "sms-topic" "[Kafka]" {
            tags "Queue"
        }
        
        website = softwareSystem "Сайт" "[PHP, React.js]" 
        
        lk = softwareSystem "Интернет-банк" "[ASP.NET MVC 4.5, .NET Framework 4.5, MSSQL]"
        
        sms_service = softwareSystem "СМС-шлюз телеком-оператора"
        
        deposits = softwareSystem "Deposits Service" "Управление заявками на депозиты, хранит актуальную информацию по условиям депозитов и по справочникам [Java, PostgreSQL, Redis]" {
            
            api = container "Deposits Api" "Предоставление API для оформления заявок на депозиты, для получения информации по условиям депозитов и по справочникам" "Java"
            
            eventconsumer = container "Deposits Event Consumer" "Обработка сообщения из шины событий" "Java"
            
            outboxprocessor = container "Deposits Outbox Processor" "Гарантия доставки событий до Kafka" "Java"
            
            db = container "Deposits Db" "PostgreSQL"
            
            cache = container "Deposits Cache" "Redis" "Кеш справочной информации"
        }
        
        abs = softwareSystem "АБС" "Автоматизированная банковская система [Delphi, Oracle]"
        
        callcenter = softwareSystem "Колл-центр"        
        
        sms_external_service = softwareSystem "Телеком-оператор" {
            tags "IsExternal"
        }
  
        # связи
  
        guest -> website
        
        website -> deposits.api "Получает информацию об актуальных условиях депозитов, сохраняет информацию о заявке"
        
        client -> lk
        
        lk -> deposits.api "Получает информацию об актуальных условиях депозитов, сохраняет информацию о заявке"
  
        front_office -> abs "Создает договора"
        back_office_deposits -> abs "Управляет ставками на депозиты, подтверждает заявки на депозиты"
        back_office_credits -> abs "Управляет ставками на депозиты"

        abs -> event_topic "Отлавливает события по заявкам, ожидающим подтверждения, публикует события по изменениям ставок по депозитам и изменении статусов заявок (подтверждено/отклонено)" "Delphi, Oracle"  
        
        deposits.eventconsumer -> sms_topic "Отправляет смс по статусам заявок"
        deposits.eventconsumer -> event_topic "Публикует события по смене статусов заявок. Отлавливает события по изменениям ставок по депозитам и изменении статусов заявок"
        deposits.eventconsumer -> deposits.db
        
        deposits.api -> abs "Получает справочную информацию"
        deposits.api -> deposits.cache "Кеширует справочную информацию"
        deposits.api -> deposits.db 
        
        deposits.outboxprocessor -> deposits.db
        deposits.outboxprocessor -> event_topic
        
        callcenter -> event_topic "Отлавливает события заявок на депозиты неавторизованных клиентов. Публикует событие изменения статуса заявки на депозит `ожидает подтверждения личности`"
        
        call_center_employee -> callcenter
        
        callcenter -> deposits "Получение информации по заявкам и актуальным предложениям по депозитам"
        
        sms_service -> sms_external_service "Отправляет смс"
        sms_service -> sms_topic "Вычитывает сообщения"
    }

    views {

        systemLandscape main "auto" {
            include *
        }
        
        container deposits {
           include *
        }
        

        # container login "login" {
        #     include * 
        #     exclude "*->*"
        #     include "relationship==*->login.api"
        #     include "relationship==login.api->*"
        #     include "relationship==login.cache->*"
        #     include "relationship==*->login.cache"
        # }
      
        
        styles {
            element "Element" {
                background #008cba
                color #ffffff
                shape RoundedBox
            }
            element "Person" {
                background #05527d
                shape person
            }
            element "Software System" {
                background #066296
            }
            element "LegendMarker" {
                background #ffffff
                width 50
                height 50
                shape RoundedBox
                opacity 0
            }
            element "Database" {
                shape cylinder
            }
            element "Queue" {
                shape pipe
            }
            element "Obsolete" {
                opacity 30
            }
            element "IsExternal" {
                background #969fa8
            }
            element "IsSecondary" {
                background #c6c5b9
            }

            relationship "Relationship" {
                style solid
                routing Curved
            }
        }
    }


}