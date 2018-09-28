Имитируем поворот айфона на отдельно взятом экране
----------------------------------

Очередной раз в моей жизни появилась задача из серии "А вот этот экран нам надо показывать в горизонтальном режиме". Раньше я как-то выкручивался, но в этот раз слегка приуныл. Во-первых в этот раз такой экран был вкладкой UITabBarController-а, т.е. презентануть его не вышло бы, а во-вторых приложение само должно было разворачивать интерфейс при перехода на чёртов экран. Но оказалось всё не так страшно...
<cut/>


Имеем две подзадачи:
1) Ограничить ориентацию табов так, чтобы один из них умел только __landscape__, а остальные только __portrait__.
2) Научить приложение поворачиваться самому при переходе на соответствующую вкладку.

Начнём как водится с первого пункта. При повороте устройства у самого верхнего контроллера текущей видимой цепочки иерархии спрашивается свойство supportedInterfaceOrientations. Звучит дико? Забейте. Это нам не понадобится :)
Ведь есть ещё одно место кода, которое срабатывает при повороте устройства и по приоритету оно поважнее будет. Это место прямо в appDelegate:
```swift
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
	if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
		if (rootViewController.responds(to: Selector(("onlyLandscape")))) {
			return .landscape;
		}
	}
	return .portrait;
}
```

Суть тут следующая. Система учуяла поворот девайса и спрашивает у нашего приложения: "Любезное приложение, вы какие ориентации предпочитаете? А то мне нужно знать поворачивать вас или нет". Ответ в нашем случае будет неоднозначный. Если мы находимся на _всегда_\__горизонтальном_\__табе_, то отвечаем .landscape, иначе .portrait. 

Для определения текущего показываемого вью-контроллера используем функцию, которую я не раз встречал в разных
местах:

```swift
private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
	if (rootViewController == nil) { return nil }
	if (rootViewController.isKind(of: UITabBarController.self)) {
		return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
	} else if (rootViewController.isKind(of: UINavigationController.self)) {
		return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
	} else if (rootViewController.presentedViewController != nil) {
		return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
	}
	return rootViewController
}
```
В кратции, она копает вглубь иерархии навигейшн, таб и презентуемых вью-контроллеров до тех пор, пока не докопается до конца. Этот конец и будет текущим показываемым вью-контроллером.

"Поворотливость" определяется  наличием метода __onlyLandscape__ у проверяемого контролллера.
```swift
	if (rootViewController.responds(to: Selector(("onlyLandscape"))))
```
Главное не забыть добавить этот метод в контроллер таба, который будет показываться горизонтально. (мы это сделаем чуть позже)

С первым пунктом разобрались -- переходим ко второму. Нам нужно чтоб интерфейс сам разворачивался на горизонтальном табе. Для этого идем в горизонтальный контроллер и прописываем небольшую хитрость во __viewDidAppear__ и __viewDidDisappear__, которая заставит айфон подумать что его повернули:
```swift
override func viewDidAppear(_ animated: Bool) {
	super.viewDidAppear(animated)
	UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
}

    
override func viewDidDisappear(_ animated: Bool) {
	super.viewDidDisappear(animated)
	UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
}	
```

Тут же вставляем метод, по которому appDelegate поймёт что это у нас горизонтальный вью-контроллер
```swift
	@objc func onlyLandscape() -> Void {}
```


Проверяем
![](https://habrastorage.org/webt/bz/dr/ci/bzdrcidck5h7gldcgdsgvpc2oqg.gif)

Ура! У нас получилось приложение, которое умеет само поворачиваться при переходне на одну из вкладок.

С рабочим примером можно ознакомиться [тут](https://github.com/funkydevil/SingleTabLandscapeMode)

Статья в которой был подсмотрен описанный метод [тут](https://medium.com/@sunnyleeyun/swift-100-days-project-24-portrait-landscape-how-to-allow-rotate-in-one-vc-d717678301c1)
