@echo off
setlocal

:: --- デバッグ用出力（ハローワールド） ---
echo =======================================
echo [Debug] 実行フォルダ: %CD%
echo [Debug] 指定ファイル: %1
echo [Debug] バッチの場所: %~dp0
echo =======================================

:: 1. ツールへのパスを設定（ダブルクォートの位置を調整）
set ASSEMBLER="%~dp0rgbasm.exe"
set LINKER="%~dp0rgblink.exe"

:: 2. 入力チェック
if "%~1"=='' (
    echo [Error] ファイル名を指定してください（例: aceb test.asm）
    exit /b 1
)

:: 引数から「パスなし・拡張子なし」の名前を取得
set TARGET_NAME=%~n1
:: 引数から「拡張子あり」の名前を取得
set TARGET_ASM=%~1

:: 3. ビルド工程
echo --- アセンブル開始: %TARGET_ASM%
%ASSEMBLER% -o "%TARGET_NAME%.o" "%TARGET_ASM%"
if %errorlevel% neq 0 (
    echo [Fail] rgbasmでエラーが発生しました。
    exit /b 1
)

echo --- リンク開始: %TARGET_NAME%.o
%LINKER% -o "%TARGET_NAME%.bin" -x -n "%TARGET_NAME%.sym" "%TARGET_NAME%.o"
if %errorlevel% neq 0 (
    echo [Fail] rgblinkでエラーが発生しました。
    exit /b 1
)

:: 4. バイナリ出力・コピー
echo --- Binary Dump (Hex) ---
if exist "%TARGET_NAME%.bin" (
    certutil -dump "%TARGET_NAME%.bin" | findstr /v "CertUtil"
    
    certutil -f -encodehex "%TARGET_NAME%.bin" temp.hex >nul
    type temp.hex | clip
    del temp.hex
)

:: 掃除
if exist "%TARGET_NAME%.o" del "%TARGET_NAME%.o"

echo ---------------------------------------
echo [Success] ビルド完了 ＆ クリップボードにコピーしました！