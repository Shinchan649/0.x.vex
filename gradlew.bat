#!/usr/bin/env cmd

@REM Windows batch file for Gradle wrapper

@REM Find Java
if defined JAVA_HOME (
    set JAVACMD=%JAVA_HOME%\bin\java.exe
) else (
    for /f "tokens=*" %%i in ('where java') do (
        set JAVACMD=%%i
        goto foundJava
    )
    echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
    exit /b 1
)

:foundJava
set APP_HOME=%~dp0..
set CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar

"%JAVACMD%" -Xmx64m -Xms64m -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*
