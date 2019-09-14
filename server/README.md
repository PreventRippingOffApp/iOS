# sechack0803サーバ

## 環境

- macOS High Sierra(ver 10.13.6)
- python3.7.1
- pip 10.0.1


## 準備

今回はvenvを使用

```
$ say "こんにちは。今日はいい天気ですね。" --data-format=LEI16@44100 -o sample1.wav
$ say "金払え、さもなくば殺すぞ" --data-format=LEI16@44100 -o sample2.wav
$ python3 -m venv venv
$ . venv/bin/activate
(venv) $ pip install --upgrade google-api-python-client
(venv) $ pip install Flask
``` 

### サンプルプログラム動作手順

```
(venv) $ python app.py
```

1. `http://localhost:5000`へアクセス
2. ハンバーガーアイコン→Uploadの順にクリックし、 `http://localhost:5000/send.html` へアクセス
3. `Select file...` をクリックし、音声ファイルを選択
4. アップロードをクリック

## リクエストとレスポンス

### リクエスト

必要となるパラメータは以下の通り。

- `audioFile` : 音声ファイル本体


### レスポンス

リクエストに対するレスポンスは、以下の属性をjson形式で返す。

- `IsThreat` : 脅威があったか、boolean型で返す。
- `Words` : 脅威の判定元となった単語をリストで返す。
- `Error` : エラーがあった場合、エラー内容を返す。

### 脅威となる単語

`Words` で返す単語のリストの中身に関して、今回は `殺す` と `金払え` の2つとした。

### リクエスト例

- sample1.wavを送った場合

```
{"Error":"","IsThreat":false,"Words":[]}
```

- sample2.wavを送った場合

```
{"Error":"","IsThreat":true,"Words":["\u6bba\u3059","\u91d1\u6255\u3048"]}
```

## 注意事項

1. APIサーバとして使用するのであれば、 `http://localhost:5000/upload` へ直接POSTリクエストを送れば良い。
2. Google Cloud Speech-to-text APIへ投げる音声データが計60分を超えた場合、有料になってしまうので、APIを使いすぎないでいただきたい。
3. もし音声データに関して問題があると思われる場合、LINEAR16の44.1kHzに変換した音声ファイル(wavになるはず)を送信するようにすると、おそらく判定してくれる。
4. 応答に時間がかかってしまうため、場合によっては10秒の音声データなどにした方が良いかもしれない。
5. 外部からサーバへアクセスする場合、上記で記載したHTTPリクエストの `localhost` の部分を、本プログラムを動作させている機器のIPアドレスに変えることで可能となる。