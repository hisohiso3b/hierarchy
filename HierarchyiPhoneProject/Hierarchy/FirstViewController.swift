//
//  FirstViewController.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/02.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let baseurl: String = "http://hiso.dip.jp:5000"
let masterID: [String] = ["5668a17c43887bdd5bf174c1", "566878c9f759de554b6a842b", "5576bb185bf0c4b00f9c995a", "5576bc325bf0c4b00f9c995b", "5575170c7995ea385f98ac79"]
let permitt_root: [String] = []

let req_permittion_dir: [String] = [
    "/運営情報",
    "/運営情報/メンテナンス、アップデート情報",
    //"/運営情報/投稿削除依頼",
    //"/運営情報/荒らし、迷惑行為報告",
    //"/運営情報/Q&A",
    //"/運営情報/root直下作成依頼",
    "/運営情報/",
    "/",
    "/使い方",
    "/使い方/ユーザーのブロックと通報",
    "/使い方/ヒエラルキーのアゲ",
    "/使い方/rootヒエラルキーへの項目追加",
    "/使い方/禁止事項",
    "/使い方/禁止事項/その他使用許諾契約に反するもの。使用許諾契約の全文を表示するにはこの投稿をタップしてください。",
    "/使い方/特定情報",
    "/使い方/pathタブについて",
    "/使い方/お気に入りとユーザー情報",
    "/使い方/投稿方法",
    "/使い方/まずはこのアプリについて説明しましょう、この投稿をタップしてください",
    "/使い方/"
]

let net = Net(baseUrlString: baseurl)

var block_users:[String] = []

class FirstViewController: UIViewController {
    
    let ud = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        if ud.stringArrayForKey("block_users") != nil{
            block_users = ud.stringArrayForKey("block_users")! as [String]
        }
            
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !ud.boolForKey("EULA") {
            let eula: String = "利用規約\nこの利用規約（以下，「本規約」といいます。）は，HISO（以下，「当組織」といいます。）がこのウェブサイト上で提供するサービス（以下，「本サービス」といいます。）の利用条件を定めるものです。登録ユーザーの皆さま（以下，「ユーザー」といいます。）には，本規約に従って，本サービスをご利用いただきます。\n\n第1条（適用）\n\n本規約は，ユーザーと当組織との間の本サービスの利用に関わる一切の関係に適用されるものとします。\n\n第2条（利用登録）\n登録希望者が当組織の定める方法によって利用登録を申請し，当組織がこれを承認することによって，利用登録が完了するものとします。\n当組織は，利用登録の申請者に以下の事由があると判断した場合，利用登録の申請を承認しないことがあり，その理由については一切の開示義務を負わないものとします。\n（1）利用登録の申請に際して虚偽の事項を届け出た場合\n（2）本規約に違反したことがある者からの申請である場合\n（3）未成年者，成年被後見人，被保佐人または被補助人のいずれかであり，法定代理人，後見人，保佐人または補助人の同意等を得ていなかった場合\n（4）反社会的勢力等（暴力団，暴力団員，右翼団体，反社会的勢力，その他これに準ずる者を意味します。）である，または資金提供その他を通じて反社会的勢力等の維持，運営もしくは経営に協力もしくは関与する等反社会的勢力との何らかの交流もしくは関与を行っていると当組織が判断した場合\n（5）その他，当組織が利用登録を相当でないと判断した場合\n\n第3条（ユーザーIDおよびパスワードの管理）\nユーザーは，自己の責任において，本サービスのユーザーIDおよびパスワードを管理するものとします。\nユーザーは，いかなる場合にも，ユーザーIDおよびパスワードを第三者に譲渡または貸与することはできません。当組織は，ユーザーIDとパスワードの組み合わせが登録情報と一致してログインされた場合には，そのユーザーIDを登録しているユーザー自身による利用とみなします。\n\n第4条（利用料金および支払方法）\nユーザーは，本サービス利用にあたり、利用料金はかかりません。ただし、当組織に損害を与えた場合その限りではありません。\n\n第5条（禁止事項）\nユーザーは，本サービスの利用にあたり，以下の行為をしてはなりません。\n\n（1）法令または公序良俗に違反する行為\n（2）犯罪行為に関連する行為\n（3）当組織のサーバーまたはネットワークの機能を破壊したり，妨害したりする行為\n（4）当組織のサービスの運営を妨害するおそれのある行為\n（5）他のユーザーに関する個人情報等を収集または蓄積する行為\n（6）他のユーザーに成りすます行為\n（7）当組織のサービスに関連して，反社会的勢力に対して直接または間接に利益を供与する行為\n（8）当組織，本サービスの他の利用者または第三者の知的財産権，肖像権，プライバシー，名誉その他の権利または利益を侵害する行為\n（9）過度に暴力的な表現，露骨な性的表現，人種，国籍，信条，性別，社会的身分，門地等による差別につながる表現，自殺，自傷行為，薬物乱用を誘引または助長する表現，その他反社会的な内容を含み他人に不快感を与える表現を，投稿または送信する行為\n（10）営業，宣伝，広告，勧誘，その他営利を目的とする行為（当組織の認めたものを除きます。），性行為やわいせつな行為を目的とする行為，面識のない異性との出会いや交際を目的とする行為，他のお客様に対する嫌がらせや誹謗中傷を目的とする行為，その他本サービスが予定している利用目的と異なる目的で本サービスを利用する行為\n（11）宗教活動または宗教団体への勧誘行為\n（12）その他，当組織が不適切と判断する行為\n\n第6条（本サービスの提供の停止等）\n当組織は，以下のいずれかの事由があると判断した場合，ユーザーに事前に通知することなく本サービスの全部または一部の提供を停止または中断することができるものとします。\n（1）本サービスにかかるコンピュータシステムの保守点検または更新を行う場合\n（2）地震，落雷，火災，停電または天災などの不可抗力により，本サービスの提供が困難となった場合\n（3）コンピュータまたは通信回線等が事故により停止した場合\n（4）その他，当組織が本サービスの提供が困難と判断した場合\n当組織は，本サービスの提供の停止または中断により，ユーザーまたは第三者が被ったいかなる不利益または損害について，理由を問わず一切の責任を負わないものとします。\n\n第7条（著作権）\nユーザーは，自ら著作権等の必要な知的財産権を有するか，または必要な権利者の許諾を得た文章，画像や映像等の情報のみ，本サービスを利用し，投稿または編集することができるものとします。\nユーザーが本サービスを利用して投稿または編集した文章，画像，映像等の著作権については，当該ユーザーその他既存の権利者に留保されるものとします。ただし，当組織は，本サービスを利用して投稿または編集された文章，画像，映像等を利用できるものとし，ユーザーは，この利用に関して，著作者人格権を行使しないものとします。\n前項本文の定めるものを除き，本サービスおよび本サービスに関連する一切の情報についての著作権およびその他知的財産権はすべて当組織または当組織にその利用を許諾した権利者に帰属し，ユーザーは無断で複製，譲渡，貸与，翻訳，改変，転載，公衆送信（送信可能化を含みます。），伝送，配布，出版，営業使用等をしてはならないものとします。\n\n第8条（利用制限および登録抹消）\n当組織は，以下の場合には，事前の通知なく，投稿データを削除し，ユーザーに対して本サービスの全部もしくは一部の利用を制限しまたはユーザーとしての登録を抹消することができるものとします。\n（1）本規約のいずれかの条項に違反した場合\n（2）登録事項に虚偽の事実があることが判明した場合\n（3）破産，民事再生，会社更生または特別清算の手続開始決定等の申立がなされたとき\n（4）1年間以上本サービスの利用がない場合\n（5）当組織からの問い合わせその他の回答を求める連絡に対して30日間以上応答がない場合\n（6）第2条第2項各号に該当する場合\n（7）その他，当組織が本サービスの利用を適当でないと判断した場合\n前項各号のいずれかに該当した場合，ユーザーは，当然に当組織に対する一切の債務について期限の利益を失い，その時点において負担する一切の債務を直ちに一括して弁済しなければなりません。\n当組織は，本条に基づき当組織が行った行為によりユーザーに生じた損害について，一切の責任を負いません。\n\n第9条（保証の否認および免責事項）\n当組織は，本サービスに事実上または法律上の瑕疵（安全性，信頼性，正確性，完全性，有効性，特定の目的への適合性，セキュリティなどに関する欠陥，エラーやバグ，権利侵害などを含みます。）がないことを明示的にも黙示的にも保証しておりません。\n当組織は，本サービスに起因してユーザーに生じたあらゆる損害について一切の責任を負いません。ただし，本サービスに関する当組織とユーザーとの間の契約（本規約を含みます。）が消費者契約法に定める消費者契約となる場合，この免責規定は適用されません。\n前項ただし書に定める場合であっても，当組織は，当組織の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害のうち特別な事情から生じた損害（当組織またはユーザーが損害発生につき予見し，または予見し得た場合を含みます。）について一切の責任を負いません。また，当組織の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害の賠償は，ユーザーから当該損害が発生した月に受領した利用料の額を上限とします。\n当組織は，本サービスに関して，ユーザーと他のユーザーまたは第三者との間において生じた取引，連絡または紛争等について一切責任を負いません。\n\n第10条（サービス内容の変更等）\n当組織は，ユーザーに通知することなく，本サービスの内容を変更しまたは本サービスの提供を中止することができるものとし，これによってユーザーに生じた損害について一切の責任を負いません。\n\n第11条（利用規約の変更）\n当組織は，必要と判断した場合には，ユーザーに通知することなくいつでも本規約を変更することができるものとします。\n\n第12条（通知または連絡）\nユーザーと当組織との間の通知または連絡は，当組織の定める方法によって行うものとします。\n\n第13条（権利義務の譲渡の禁止）\nユーザーは，当組織の書面による事前の承諾なく，利用契約上の地位または本規約に基づく権利もしくは義務を第三者に譲渡し，または担保に供することはできません。\n\n第14条（準拠法・裁判管轄）\n本規約の解釈にあたっては，日本法を準拠法とします。\n本サービスに関して紛争が生じた場合には，当組織の本店所在地を管轄する裁判所を専属的合意管轄とします。\n\n第15条（不快、攻撃的なコンテンツ表示）\n本アプリケーションの特徴上、あなたにとって不快なコンテンツ、攻撃的なコンテンツが表示されることがあります。\nあなたが有害だと感じたとしても、コンテンツの削除は当組織の判断となります。\n\nThe communication program \"Hierarchy\" is allow to use agree these provisions.\n【copyright】\n2015 HISO all right reserved."
            
            let alertController = UIAlertController(title: "End-User Lisence Agreement", message: eula, preferredStyle: .Alert)
            let otherAction = UIAlertAction(title: "Agree", style: .Default) {
                action in print("pushed OK!")
                
                self.ud.setObject(true, forKey: "EULA")
                
                if self.ud.boolForKey("EULA") {
                    
                    if(self.ud.stringForKey("name") == nil || self.ud.stringForKey("id") == nil){
                        Alamofire.request(.GET, baseurl + "/create_user")
                            .responseJSON { res in
                                switch res.result {
                                case .Success:
                                    print(res.result.value)
                                    var res_json = JSON(res.result.value!)
                                    self.ud.setObject(res_json[0]["name"].string, forKey: "name")
                                    self.ud.setObject(res_json[0]["_id"].string, forKey: "id")
                                    
                                    print(self.ud.stringForKey("name")!)
                                    print(self.ud.stringForKey("id")!)
                                    
                                    //red:0.863, green:0.078, blue:0.235, alpha: 1.0
                                    let params =
                                    [
                                        "userid": res_json[0]["_id"].string!,
                                        "name": res_json[0]["name"].string!,
                                        "image_num": 1,
                                        "red": 0.137,
                                        "green": 0.922,
                                        "blue": 0.765
                                    ]
                                    print("setJSON")
                                    print(params)
                                    
                                    let jsonparams = JSON(params)
                                    print(jsonparams.dictionary!)
                                    
                                    
                                    net.POST("/user_update", params: params, successHandler: {
                                        responseData in
                                        //let result = responseData.json(error: nil)
                                        NSLog("Success")
                                        
                                        let url = NSURL(string: baseurl+"/get_image/\(1)")
                                        var err: NSError?
                                        let imageData :NSData = NSData(contentsOfURL: url!)!
                                        var img = UIImage(data:imageData)
                                        
                                        self.ud.setObject(UIImageJPEGRepresentation(img!, 0.7), forKey: "mybackimage")
                                        self.ud.setInteger(1, forKey: "image_num")
                                        self.navigationController?.popViewControllerAnimated(true)
                                        
                                        let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabController")
                                        self.presentViewController(next, animated: true, completion: nil)
                                        
                                        }, failureHandler: { error in
                                            NSLog("Error")
                                            self.ud.setObject(nil, forKey: "id")
                                            exit(0)
                                    })
                                    break;
                                case .Failure(let error):
                                    print(error)
                                }
                        }
                    }else{
                        let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabController") 
                        self.presentViewController(next, animated: true, completion: nil)
                    }
                    
                }
            }
            let cancelAction = UIAlertAction(title: "DISAGREE", style: .Cancel) {
                action in
                print("Pushed CANCEL!")
                exit(0)
            }
            
            alertController.addAction(otherAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        if ud.boolForKey("EULA") {
            
            if(ud.stringForKey("name") == nil || ud.stringForKey("id") == nil){
                Alamofire.request(.GET, baseurl + "/create_user")
                    .responseJSON { (res) in
                        print(res.result.value)
                        var res_json = JSON(res.result.value!)
                        self.ud.setObject(res_json[0]["name"].string, forKey: "name")
                        self.ud.setObject(res_json[0]["_id"].string, forKey: "id")
                        
                        print(self.ud.stringForKey("name")!)
                        print(self.ud.stringForKey("id")!)
                        
                        //red:0.863, green:0.078, blue:0.235, alpha: 1.0
                        var params =
                        [
                            "userid": res_json[0]["_id"].string!,
                            "name": res_json[0]["name"].string!,
                            "image_num": 1,
                            "red": 0.137,
                            "green": 0.922,
                            "blue": 0.765
                        ]
                        print("setJSON")
                        print(params)
                        
                        var jsonparams = JSON(params)
                        print(jsonparams.dictionary!)
                        
                        
                        net.POST("/user_update", params: params, successHandler: {
                            responseData in
                            //let result = responseData.json(error: nil)
                            NSLog("Success")
                            
                            let url = NSURL(string: baseurl+"/get_image/\(1)")
                            var err: NSError?
                            let imageData :NSData = NSData(contentsOfURL: url!)!
                            let img = UIImage(data:imageData)
                            
                            self.ud.setObject(UIImageJPEGRepresentation(img!, 0.7), forKey: "mybackimage")
                            self.ud.setInteger(1, forKey: "image_num")
                            self.navigationController?.popViewControllerAnimated(true)
                            
                            let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabController") 
                            self.presentViewController(next, animated: true, completion: nil)
                            
                            }, failureHandler: { error in
                                NSLog("Error")
                                self.ud.setObject(nil, forKey: "id")
                                exit(0)
                        })
                        
                }
            }else{
                let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("TabController") 
                presentViewController(next, animated: true, completion: nil)
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
