# racing-db
Datenbank-Scripts

Im setup.sql werden alle Objekte der DB erstellt. Das sind Tabellen, Prozeduren und Views. Auf dem Server läuft MySql (nicht MariaDB!) und der ist leider etwas limitiert in der Funktionalität.

Grundsätzlich greift der "Client" (API-Services) nur auf die SPs zu. Die Datenbank ist zudem mehrsprachig angelegt (Inhalte) und Unicode technisch.
