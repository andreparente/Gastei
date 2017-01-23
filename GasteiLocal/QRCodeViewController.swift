//
//  QRCodeViewController.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 3/23/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate, UINavigationBarDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    var link:String!
    var valorfinal:String = ""
    var datafinalmente:String = ""
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var contglobal=0
    var delegate = GastoManualViewController()
    let back = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text="No QR code is detected"
        back.setTitle("Voltar", for: UIControlState())
        back.setTitleColor(UIColor.blue, for: UIControlState())
        back.frame = CGRect(x: 15, y: 15, width: 100, height: 100)
        back.addTarget(self, action: #selector(QRCodeViewController.pressed(_:)), for: .touchUpInside)
        let captureDevice=AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var input : AnyObject!
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch _ {
            print("hata")
        }
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
        view.bringSubview(toFront: messageLabel)
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        
        
        
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 53))
        navigationBar.barTintColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 18)!]
        navigationBar.delegate = self
        let leftButton =  UIBarButtonItem(title: "Voltar", style:   UIBarButtonItemStyle.plain, target: self, action: #selector(QRCodeViewController.pressed(_:)))
        leftButton.tintColor = UIColor.white
        leftButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 15)!], for: UIControlState())
        
        
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        
        
        
        
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront: qrCodeFrameView!)
        view.addSubview(back)
        view.bringSubview(toFront: back)

    }
    
    func pressed(_ sender: UIButton!) {
       dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Identifica QRCode
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //Ve se o array não é nil e se tem pelo menos um objeto.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Objeto de metadata
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds.
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil  && contglobal==0 {
                print(metadataObj.stringValue)
                link = metadataObj.stringValue
                (valorfinal,datafinalmente)=reconheceUrl(link)
                print(datafinalmente)
                print(valorfinal)
                
                // desfaz o segue
                self.delegate.valortotal = Double(valorfinal)?.roundToPlaces(2)
                self.delegate.dataQR = datafinalmente
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let datefromstring = dateFormatter.date(from: self.delegate.dataQR)
                self.delegate.datePicker.date = datefromstring!
                
                self.delegate.valor.text=String(self.delegate.valortotal)
                dismiss(animated: true, completion: nil)
                
                contglobal += 1
                return
            }
        }
    }
    // MARK: - Reconhece Link
    func reconheceUrl(_ link:String)->(String,String)
    {
        //Vetor de char pra armazenar a url recebida
        let characters=Array(link.characters)
        print(characters)
        //Variaveis uteis
        var j=0;var n=0;var x=0;let i=characters.count;var z=0;var w=0
        var valor:[String]! = ["",""]
        var valorfinalmutavel:String! = ""
        var datatotal:[String]! = [""]
        var data:[String]!=[""]
        var valoremhexa:String! = ""
        var datafinal:String!
        
        for  j in 0...i
        {
            //Quando encontrar vN entra no if.O if insere o valor em um array de string
            if(characters[j] == "v" && characters[j+1] == "N")
            {
                n=j+4
                while(characters[n] != "&")
                {
                    valor.insert(String(characters[n]), at: x)
                    n += 1;x += 1;
                }
                break
            }
            else
            {
                if (characters[j]=="d" && characters[j+1]=="h")
                {
                    z=j+6
                    while(characters[z] != "&")
                    {
                        datatotal.insert(String(characters[z]), at: w)
                        z += 1;w += 1;
                    }
                }
            }
        }
        j=0
        w=0
        if datatotal != nil
        {
        while(datatotal[j] != "5" && datatotal[j+1] != "4")
        {
            data.insert(datatotal[j],at: w)
            j+=1;w+=1
        }
        if data != nil
        {
            for char1 in data
            {
                if char1 != ""
                {
                    valoremhexa.append(Character(char1))
                }
            }
        }
        datafinal=hexStringtoAscii(valoremhexa)
        }
        //Quando quebrar o loop passa o valor pra uma string só
        if valor != nil
        {
            
            for char in valor
            {
                if char != ""
                {
                    valorfinalmutavel.append(Character(char))
                }
            }
        }
        return (valorfinalmutavel,datafinal)
    }
    
    func hexStringtoAscii(_ hexString : String) -> String {
        
        let pattern = "(0x)?([0-9a-f]{2})"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = hexString as NSString
        let matches = regex.matches(in: hexString, options: [], range: NSMakeRange(0, nsString.length))
        let characters = matches.map {
            Character(UnicodeScalar(UInt32(nsString.substring(with: $0.rangeAt(2)), radix: 16)!)!)
        }
        return String(characters)
    }
}
