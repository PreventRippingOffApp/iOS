# coding: utf-8

from flask import Flask, render_template, request, jsonify
from werkzeug import secure_filename
import base64
from googleapiclient import discovery
import httplib2
import sys

# 設定確認
app = Flask(__name__, instance_relative_config=True)
app.config.from_object('config.Test') # 設定ファイル読み込み(DISCOVERY_URL)
app.config.from_pyfile('instance_config.cfg') # APIキー読み込み(API_KEY)
if not app.config['DISCOVERY_URL'] or not app.config['API_KEY']:
    print('DISCOVERY_URL or API_KEY not exists')
    sys.exit(1)

# Google Cloud Speech-to-text APIへの通信準備
http = httplib2.Http()
service = discovery.build(
    'speech', 'v1', http=http, discoveryServiceUrl=app.config['DISCOVERY_URL'], developerKey=app.config['API_KEY']
)

@app.route('/send')
@app.route('/send.html')
def send_file():
    return render_template('send.html', title='SecHack0803')


@app.route('/upload', methods=['GET', 'POST'])
def render_upload():
    if request.method == 'POST':
        result = {
            'IsThreat': "False",
            'Words': [],
            'Error': ''
        }
        # 音声ファイル確認
        #print(request.json['sound']['file_data'])
        #if 'audioFile' not in request.files:
        #    result['Error'] = 'audioFile is not exists'
        #    return jsonify(result)
        #if 'audio' not in request.files['audioFile'].content_type:
        #    result['Error'] = 'audioFile is not audio file format'
        #    return jsonify(result)
        # APIへ投げるための下準備
        audioData = request.json['sound']['file_data']
        with open('file', mode='w') as f:
            f.write(audioData)

        #print(audioData)
        audioRequest = service.speech().recognize(
            body={
                'config': {
                    'encoding': 'LINEAR16',
                    'sampleRateHertz': 44100,
                    'languageCode': 'ja-JP',
                    'enableWordTimeOffsets': 'false',
                },
                'audio': {
                    'content': audioData
                    }
                }
        )
        audioResponse = audioRequest.execute()
        print('audioResponse=' + str(audioResponse))

        # 脅威の検知
        for res in audioResponse["results"]:
            for sentence in res['alternatives']: 
                if '殺す' in sentence['transcript']:
                    result['Words'].append('殺す')
                if '金払え' in sentence['transcript']:
                    result['Words'].append('金払え')
        if len(result['Words']) > 0:
            result['IsThreat'] = "True"

        print('result=' + str(result))
        # 結果の送信
        return jsonify(result)


@app.route('/')
@app.route('/index')
@app.route('/index.html')
def render_index():
    return render_template('index.html', title='SecHack0803')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
