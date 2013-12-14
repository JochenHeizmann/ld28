Strict

Import mojo
Import fairlight

Import src.scenegame

Function Main%()
    Local app := New BaseApplication()
    app.SetVirtualSize(640, 480)
    app.keepDisplayRatio = True
    app.GetSceneManager().fader = New SolidFader()
    app.GetSceneManager().Add("game", New SceneGame())
    Return 0
End
