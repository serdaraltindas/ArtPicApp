//
//  detailsVC.swift
//  ArtPicApp
//
//  Created by Serdar Altındaş on 12.03.2023.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
    super.viewDidLoad()
        saveButton.isHidden = true
        if chosenPainting != "" {
            //coredata
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count>0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey:"artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                }
                }
            }catch{
                print("ERROR!")
            }
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
//RECOGNIZER
//7.ADIM : KULLANICI İÇİN FOTOĞRAF EKLEDİK VE BU FOTOĞRAFIN TIKLANABİLİR OLMASINI İSTİYORUZ.
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
//4.ADIM : KULLANICI BOŞ BİR YERE TIKLADIĞINDA KLAVYE KAPANACAK.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//6.ADIM : HER DOKUNUŞU ALGILAYAN RECOGNIZER'I TABLEVIEW EKRANININ KENDİSİNE EKLİYORUZ.
        view.addGestureRecognizer(gestureRecognizer)
    }
//8.ADIM : SEÇİLEN FOTOĞRAFA NE OLACAĞINI YAZACAĞIZ VE KULLANICI FOTOĞRAFA DOKUNDUĞU ZAMAN GALERİYE VEYA DİREKT KAMERAYA ERİŞEBİLECEK.
    @objc func selectImage (){
//9.ADIM : DELEGATE İLE ÜST KISIMDAKİ SINIFLARI EKLEDİK, SOURCETYPE İLE KAMERA VE GALERİDEN ALMA SEÇENEKLERİNİ EKLEDİK, ALLOWS EDİTİNG İLE EDİTLEMEYE UYGUN HALE GETİRDİK, PRESENT İLE EKLEME İŞLEMİ YAPTIK.
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
//10.ADIM : FOTOĞRAFI ÜST KISIMDA EKLEDİK ANCAK DAHA SONRA NE OLACAĞINI YAZMADIK ŞİMDİ İSE NE OLACAĞINI YAZACAĞIZ.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
//11.ADIM : YUKARIDA AÇTIĞIMIZ PİCKER'I KAPATMAK İÇİN BU KODU EKLEDİK.
        self.dismiss(animated: true)
    }
//5.ADIM : EKRAN ÜZERİNDE OLAN TÜM ETKİNLİKLERİ SONLANDIRIR.
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
            
        //12.ADIM : CORE DATAYA BİLGİ EKLEMEK İÇİN BU KOD SATIRLARINI KULLANIYORUZ.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //13.ADIM = PAINTINGS İÇİNE GİRİLEN DEĞERLER.
                                                                                        
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        //IF-LET DÖNGÜSÜNE ALMA SEBEBİMİZ KULLANICI TARAFINDAN SADECE RAKAM GİRİLMESİNİ İSTEMEMİZ.
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        //14.ADIM = GÖRSELİ NASIL DATA HALİNE GETİRİYORUZ VE DAHA SONRA KULLANIYORUZ.
        let data = imageView.image!.jpegData(compressionQuality: 0.4)
        newPainting.setValue(data, forKey: "image")
        do{
            try context.save()
            print("SUCCES!")
        }catch{
            print("ERROR!")
        }
        //NOTIFICATION KULLANARAK VİEW CONTROLLER ARASINDA BAĞLANTI KURABİLİRİZ.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        //BİR ÖNCEKİ VİEW CONTROLLER EKRANINA GERİ DÖNMEK İÇİN KULLANIYORUZ.
       
    }
}
