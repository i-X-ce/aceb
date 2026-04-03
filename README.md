# ACEB Tool

## 導入方法

1. **必要なファイルのダウンロード**:
   - [公式サイト](https://rgbds.gbdev.io/) から RGBDS を導入します。
   - Windows: `rgbasm.exe`, `rgblink.exe`
   - Linux: `rgbasm`, `rgblink`

1. **環境変数の設定**:
   - ダウンロードしたファイルを任意のフォルダに配置します。
   - 環境変数 `PATH` にそのフォルダのパスを追加します。
     - Windowsの場合:
       1. スタートメニューを右クリックし、「システム」を選択。
       1. 「システムの詳細設定」をクリック。
       1. 「環境変数」をクリック。
       1. 「システム環境変数」セクションで `Path` を選択し、「編集」をクリック。
       1. 新しいパスを追加し、「OK」をクリック。

## Linuxでの使い方

1. 必要コマンドをインストールします（環境に応じて）。
   - RGBDS: `rgbasm`, `rgblink`
   - Hex表示: `xxd`（通常は `vim-common` パッケージに含まれます）
   - クリップボード: `wl-copy`（Wayland）または `xclip` / `xsel`（X11）

1. `aceb.sh` に実行権限を付与します。

   ```bash
   chmod +x aceb.sh
   ```

1. `.asm` をビルドしてHex文字列をクリップボードにコピーします。

   ```bash
   ./aceb.sh yourfile.asm
   ```

1. `.bin` を直接読み込んでHex出力・コピーすることもできます。

   ```bash
   ./aceb.sh yourfile.bin
   ```

## Linuxで`aceb`コマンドとして登録する

方法1（推奨）: シンボリックリンクを作成

```bash
sudo ln -sf "$(pwd)/aceb.sh" /usr/local/bin/aceb
```

方法2: `~/.local/bin` にリンクしてPATHへ追加

```bash
mkdir -p ~/.local/bin
ln -sf "$(pwd)/aceb.sh" ~/.local/bin/aceb
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

登録後は次のように実行できます。

```bash
aceb yourfile.asm
aceb yourfile.asm -f
```

## 使用方法

1. コマンドプロンプトまたはPowerShellを開きます。
1. `aceb.bat` を実行し、引数としてアセンブリファイルを指定します。
   ```
   aceb yourfile.asm
   ```
1. ビルドが成功すると、出力ファイルが生成され、16進数形式でクリップボードにコピーされます。

## オプション

- `-f`: 整形モードでクリップボードにコピーします。

Linux例:

```bash
./aceb.sh yourfile.asm -f
```
