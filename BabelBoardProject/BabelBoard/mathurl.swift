func math(message: String) -> String? {
    myparams = ["X-Parse-Application-Id": "u19o03YiCWzeonVWaTNueubVC8UupUiP7HVibWF1", "X-Parse-REST-API-Key": "BY0NkbNymGC0n0pK3TicPHIosksEdK2DG8M1uCzE", "Content-Type": "application/json", "message": message]
    Alamofire.request(.GET, "https://api.parse.com/1/functions/math/get", parameters: myparams)
        .responseString { (request, response, string, error) in
            println(string)
        }
}