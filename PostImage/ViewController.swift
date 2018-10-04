//
//  ViewController.swift
//  PostImage
//
//  Created by sanwa on 2018/10/03.
//  Copyright © 2018年 g015c1124. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet weak var imageView: UIImageView!
  var pickedImage: UIImage? //選択されたイメージを保存するためのインスタンス変数
  let boundary = "----WebKitFormBoundaryZLdHZy8HNaBmUX0d"
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  @IBAction func imageSelect(_ sender: Any) {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      // 写真を選ぶビュー
      let pickerView = UIImagePickerController()
      // 写真の選択元をカメラロールにする
      // 「.camera」にすればカメラを起動できる
      pickerView.sourceType = .photoLibrary
      // デリゲート
      pickerView.delegate = self
      // ビューに表示
      self.present(pickerView, animated: true)
    }
  }
  
  @IBAction func imageUpload(_ sender: Any) {
    // UIImageからJPEGに変換してアップロード
    let imageData = UIImageJPEGRepresentation(pickedImage!, 0.5)!
    let body = httpBody(imageData, fileName: "image.jpg")
    let url = URL(string: "http://192.168.100.104:3000/api/v1/image/upload")!
    
    fileUpload(url, data: body) {(data, response, error) in
      if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
        if response.statusCode == 200 {
          print("Upload done")
        } else {
          print(response.statusCode)
        }
      }
    }
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    // 選択した写真を取得する
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//    //比率を変えずに画像を表示する(空白が生じる)
//    imageView.contentMode = .scaleAspectFit
    self.pickedImage = image
    // ビューに表示する
    self.imageView.image = image
    
    
    // 写真を選ぶビューを引っ込める
    self.dismiss(animated: true)
  }
  
  func httpBody(_ fileAsData: Data, fileName: String) -> Data {
    var data = "--\(boundary)\r\n".data(using: .utf8)!
    // サーバ側が想定しているinput(type=file)タグのname属性値とファイル名をContent-Dispositionヘッダで設定
    data += "Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
    data += "Content-Type: image/jpeg\r\n".data(using: .utf8)!
    data += "\r\n".data(using: .utf8)!
    data += fileAsData
    data += "\r\n".data(using: .utf8)!
    data += "--\(boundary)--\r\n".data(using: .utf8)!
    
    return data
  }
  // リクエストを生成してアップロード
  func fileUpload(_ url: URL, data: Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // マルチパートでファイルアップロード
    let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    let urlConfig = URLSessionConfiguration.default
    urlConfig.httpAdditionalHeaders = headers
    
    let session = Foundation.URLSession(configuration: urlConfig)
    let task = session.uploadTask(with: request, from: data, completionHandler: completionHandler)
    task.resume()
  }
}

