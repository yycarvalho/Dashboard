@echo off
SETLOCAL ENABLEEXTENSIONS

REM -------------------------------------
REM Configuração do Java
SET JAVA_HOME=C:\Program Files\Java\jdk-11.0.4
SET PATH=%JAVA_HOME%\bin;%PATH%

REM -------------------------------------
REM Start do servidor
echo Iniciando Sistema de Pedidos API...
java -Dfile.encoding=UTF8 -Duser.timezone=GMT-3 -Xms1024m -Xmx1024m -cp "build\classes;lib/*" com.sistema.pedidos.controller.ApiController 8080

REM -------------------------------------
REM Se quiser usar parâmetros mais avançados, descomente a linha abaixo
REM java -server -Xmx1536m -Xms1024m -Xmn512m -XX:PermSize=256m -XX:SurvivorRatio=8 -Xnoclassgc -XX:+AggressiveOpts -cp "build\classes;lib/*" com.sistema.pedidos.controller.ApiController 8080

ENDLOCAL
