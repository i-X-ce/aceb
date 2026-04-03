#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================="
echo "[Debug] 実行フォルダ: $(pwd)"
echo "[Debug] 指定ファイル: ${1-}"
echo "[Debug] バッチの場所: ${SCRIPT_DIR}/"
echo "======================================="

# アセンブラとリンカのパスを指定（必要に応じて変更してください）
ASSEMBLER="${HOME}/rgbds/rgbasm"
LINKER="${HOME}/rgbds/rgblink"

copy_to_clipboard() {
	local text="$1"

	if command -v wl-copy >/dev/null 2>&1; then
		printf "%s" "$text" | wl-copy
		return 0
	fi

	if command -v xclip >/dev/null 2>&1; then
		printf "%s" "$text" | xclip -selection clipboard
		return 0
	fi

	if command -v xsel >/dev/null 2>&1; then
		printf "%s" "$text" | xsel --clipboard --input
		return 0
	fi

	if command -v pbcopy >/dev/null 2>&1; then
		printf "%s" "$text" | pbcopy
		return 0
	fi

	return 1
}

if [[ $# -lt 1 ]]; then
	echo "[Error] ファイル名を指定してください（例: aceb test.asm）"
	exit 1
fi

TARGET_FILE="$1"
TARGET_NAME="$(basename "${TARGET_FILE%.*}")"
TARGET_EXT=".${TARGET_FILE##*.}"
TARGET_ASM="$1"
OPTION="${2-}"

shopt -s nocasematch
if [[ "$TARGET_EXT" == ".bin" ]]; then
	echo "--- Mode: バイナリ出力モード ---"
	BIN_FILE="$TARGET_FILE"
	goto_output=true
else
	goto_output=false
fi
shopt -u nocasematch

if [[ "$goto_output" != true ]]; then
	shopt -s nocasematch
	if [[ "$TARGET_EXT" != ".asm" ]]; then
		echo "[Error] 対応している拡張子は.asmのみです。"
		shopt -u nocasematch
		exit 1
	fi
	shopt -u nocasematch

	echo "--- アセンブル開始 ${TARGET_ASM}"
	"$ASSEMBLER" -o "${TARGET_NAME}.o" "$TARGET_ASM"
	if [[ $? -ne 0 ]]; then
		echo "[Fail] rgbasmでエラーが発生しました。"
		exit 1
	fi

	echo "--- リンク開始: ${TARGET_NAME}.o"
	"$LINKER" -o "${TARGET_NAME}.bin" -x -n "${TARGET_NAME}.sym" "${TARGET_NAME}.o"
	BIN_FILE="${TARGET_NAME}.bin"
	if [[ $? -ne 0 ]]; then
		echo "[Fail] rgblinkでエラーが発生しました。"
		exit 1
	fi
fi

echo "--- Binary Dump (Hex) ---"
if [[ -f "$BIN_FILE" ]]; then
	xxd "$BIN_FILE"

	if [[ "$OPTION" == "-f" ]]; then
		echo "[Info] 整形モードでクリップボードにコピーします..."
		hex_text="$(hexdump -v -e '16/1 "%02X " "\n"' "$BIN_FILE")"
	else
		echo "[Info] 通常モードでクリップボードにコピーします..."
		hex_text="$(xxd -p "$BIN_FILE" | tr -d '\n')"
	fi

	if ! copy_to_clipboard "$hex_text"; then
		echo "[Warn] クリップボードにコピーできませんでした。wl-copy / xclip / xsel が必要です。"
	fi
fi

if [[ -f "${TARGET_NAME}.o" ]]; then
	rm -f "${TARGET_NAME}.o"
fi

echo "---------------------------------------"
echo "[Success] ビルド完了 ＆ クリップボードにコピーしました！"
