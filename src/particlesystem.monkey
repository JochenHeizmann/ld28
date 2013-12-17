Strict

Import fairlight
Import level
Import particle

Class ParticleSystem
    Global img:Image

    Const MAX_PARTICLES% = 100

    Field particle:Particle[MAX_PARTICLES]

    Method New(l:Level)
        Particle.level = l
        For Local i := 0 Until MAX_PARTICLES
            particle[i] = New Particle
        Next
    End

    Method LaunchParticle:Void(x#, y#, veloX#, veloY#, lifetime# = 120.0, gravity# = 0.0, type% = Particle.TYPE_WHITE, collideWithLevelGeometry? = True)
        Local p := GetUnusedParticle()
        If (p)
            p.alpha = 1.0
            p.inUse = True
            p.type = type
            p.position.x = x
            p.position.y = y
            p.velocity.x = veloX
            p.velocity.y = veloY
            p.gravity = gravity
            p.lifetime = lifetime
            p.livedFor = 0
            p.collideWithLevelGeometry = collideWithLevelGeometry
        End
    End

    Method LaunchParticleDust:Void(x#, y#)
        For Local i% = 0 To 3
            Local dy := Rnd(-0.2, 0.0)
            LaunchParticle(x, y, Rnd(-1, 1), dy, 5.0, 0, Particle.TYPE_WHITE, False)
        Next
    End

    Method LaunchParticleSparkle:Void(x#, y#)
        If (Rnd(0,2) >= 1)
            LaunchParticle(x, y, Rnd(-1, 1), Rnd(-1, 1), 7.0, 0.06, Particle.TYPE_BROWN, False)
        Else
            LaunchParticle(x, y, Rnd(-1, 1), Rnd(-1, 1), 7.0, 0.06, Particle.TYPE_RED, False)
        End
    End

    Method LaunchParticleDoor:Void(x#, y#)
        LaunchParticle(x, y, Rnd(-1, 1), Rnd(-0.2, 0), 7.0, 0, Particle.TYPE_BROWN, False)
        LaunchParticle(x, y, Rnd(-1, 1), Rnd(-0.2, 0), 7.0, 0, Particle.TYPE_BROWN, False)
    End

    Method LaunchParticleExplosion:Void(x#, y#)
        Local count := Rnd(5, 15)
        Local radius# = 1.0
        For Local i% = 0 To count
            LaunchParticle(x, y, Rnd(-radius, radius), Rnd(-radius, radius), 10.0, 0, Particle.TYPE_RED, False)
        Next
    End

    Method LaunchParticleGlass:Void(x#, y#, dx#)
        LaunchParticle(x, y, dx, Rnd(0, -1), 10.0, 0.2, Particle.TYPE_WHITE, False)
    End

    Method GetUnusedParticle:Particle()
        For Local i := 0 Until MAX_PARTICLES
            If (Not particle[i].inUse) Then Return particle[i]
        Next
        Return Null
    End

    Method OnUpdate:Void(delta#)
        For Local i := 0 Until MAX_PARTICLES
            If (particle[i].inUse) Then particle[i].OnUpdate(delta)
        Next
    End

    Method OnRender:Void()
        For Local i := 0 Until MAX_PARTICLES
            If (particle[i].inUse)
                SetAlpha(particle[i].alpha)
                DrawImage img, particle[i].position.x, particle[i].position.y, particle[i].type
            End
        Next
        SetAlpha(1.0)
    End
End