#coding:utf8
import base64
from googleapiclient import discovery
import httplib2
 
#APIキーを設定
key = "AIzaSyDql17iDkYjvW9Re7HqZPWvbrlexu9Uvwo"
 
#音声認識に使うファイル名
speech_file = "sample1.wav"
 
#URL情報
DISCOVERY_URL = ('https://{api}.googleapis.com/$discovery/rest?version={apiVersion}')
 
#APIの情報を返す関数
def get_speech_service():
    http = httplib2.Http()
    return discovery.build(
        'speech', 'v1', http=http, discoveryServiceUrl=DISCOVERY_URL, developerKey=key
    )
 
 
 
#SpeechAPIによる認識結果を保存
if __name__ == '__main__':
    #音声ファイルを開く
    with open(speech_file, 'rb') as speech:
        speech_content = base64.b64encode(speech.read()) 
     
    #APIの情報を取得して、音声認識を行う
    service = get_speech_service()
    service_request = service.speech().recognize(
        body={
            'config': {
                'encoding': 'LINEAR16',
                'sampleRateHertz': 44100,
                'languageCode': 'ja-JP', #日本語に設定
                'enableWordTimeOffsets': 'false',
            },
            'audio': {
                'content': speech_content.decode('UTF-8')
                }
            })
    response = service_request.execute()
    print(response)
