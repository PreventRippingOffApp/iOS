#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, request, jsonify
app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False  # JSONでの日本語文字化け対策
@app.route('/', methods=['POST'])
def post_json():
    json = request.get_json()  # POSTされたJSONを取得
    print(json)
    dic = {
        'foo': 'bar',
        'ほげ': 'ふが'
    }
    return jsonify(dic)
@app.route('/', methods=['GET'])
def get_json_from_dictionary():
    dic = {
        'foo': 'bar',
        'ほげ': 'ふが'
    }
    return jsonify(dic)  # JSONをレスポンス
