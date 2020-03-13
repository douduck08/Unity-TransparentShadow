using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DouduckLib;

public class TransparentShadowManager : Singleton<TransparentShadowManager> {

    List<TransparentShadowLight> lights = new List<TransparentShadowLight> ();
    List<TransparentShadowCaster> casters = new List<TransparentShadowCaster> ();

    public void Register (TransparentShadowLight light) {
        lights.Add (light);
    }

    public void Unregister (TransparentShadowLight light) {
        lights.Remove (light);
    }

    public void Register (TransparentShadowCaster caster) {
        casters.Add (caster);
    }

    public void Unregister (TransparentShadowCaster caster) {
        casters.Remove (caster);
    }

    public List<TransparentShadowLight> GetLights () {
        return lights;
    }

    public List<TransparentShadowCaster> GetCasters () {
        return casters;
    }
}