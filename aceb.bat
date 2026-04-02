@echo off
setlocal

:: --- デバッグ用出力（ハローワールド） ---
echo =======================================
echo [Debug] 実行フォルダ: %CD%
echo [Debug] 指定ファイル: %1
echo [Debug] バッチの場所: %~dp0
echo =======================================

:: ツールへのパスを設定（ダブルクォートの位置を調整）
set ASSEMBLER="%~dp0rgbasm.exe"
set LINKER="%~dp0rgblink.exe"

:: 入力チェック
if "%~1"=='' (
    echo [Error] ファイル名を指定してください（例: aceb test.asm）
    exit /b 1
)

:: 引数からフルパスのファイル名を取得
set TARGET_FILE=%~1
:: 引数から「パスなし・拡張子なし」の名前を取得
set TARGET_NAME=%~n1
:: 引数から拡張子の部分を取得
set TARGET_EXT=%~x1
:: 引数から「拡張子あり」の名前を取得
set TARGET_ASM=%~1
:: オプション引数を取得
set OPTION=%~2

if /i "%TARGET_EXT%"==".bin" (
    echo --- Mode: バイナリ出力モード ---
    set BIN_FILE=%TARGET_FILE%
    goto output
)

if /i not "%TARGET_EXT%"==".asm" (
    echo [Error] 対応している拡張子は.asmのみです。
    exit /b 1
)

:: ビルド工程
echo --- アセンブル開始 %TARGET_ASM%
%ASSEMBLER% -o "%TARGET_NAME%.o" "%TARGET_ASM%"
if %errorlevel% neq 0 (
    echo [Fail] rgbasmでエラーが発生しました。
    exit /b 1
)

echo --- リンク開始: %TARGET_NAME%.o
%LINKER% -o "%TARGET_NAME%.bin" -x -n "%TARGET_NAME%.sym" "%TARGET_NAME%.o"
set BIN_FILE=%TARGET_NAME%.bin
if %errorlevel% neq 0 (
    echo [Fail] rgblinkでエラーが発生しました。
    exit /b 1
)

:: バイナリ出力・コピー
:output
echo --- Binary Dump (Hex) ---
if exist "%BIN_FILE%"  (
    certutil -dump "%BIN_FILE%" | findstr /v "CertUtil"
    
    if /i "%OPTION%"=="-f" (
        echo [Info] 整形モードでクリップボードにコピーします...
        certutil -f -encodehex "%BIN_FILE%" temp.hex 10 >nul
        type temp.hex | clip
    ) else (
        echo [Info] 通常モードでクリップボードにコピーします...
        powershell -Command "$b = [System.IO.File]::ReadAllBytes('%BIN_FILE%'); $s = ($b | ForEach-Object { '{0:x2}' -f $_ }) -join ''; Set-Clipboard $s"
    )
    del temp.hex
)

:: 掃除
if exist "%TARGET_NAME%.o" del "%TARGET_NAME%.o"

echo ---------------------------------------
echo [Success] ビルド完了 ＆ クリップボードにコピーしました！