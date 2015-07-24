using UnityEngine;

[ExecuteInEditMode]
public class Mirror_3 : MonoBehaviour {

    private RenderTexture refTex;
    private Matrix4x4 correction;
    private Matrix4x4 projM;
    private Matrix4x4 world2ProjView;
    private Matrix4x4 cm;
    private Camera mirCam;
    private bool busy;

    //======================

    [Range(32, 1024)]
    public int m_renderSize = 128;

    public LayerMask m_ReflectLayers = -1;

    private Transform m_Transform;
    private Renderer m_Renderer;

    private Camera m_mainCamera;
    private Transform m_mainCameraTransform;

    private Vector3 m_v3RotationMirrored;
    private Transform m_mirCamTransform;

    private Vector4 m_v4CameraSpacePlane;
    private Vector4 m_v4ClipPlane;

    private const string REF_TEX_PROPERTY_NAME = "_RefTex";
    private const string PROJ_MAT_PROPERTY_NAME = "_ProjMat";


    //======================

    void Start ( ) {    
        if (mirCam) return;        

        initMirrorCamera( );
        initComponent( );
        initRenderTexture( );
        initCorrectionMatrix( );
        initValue( );
    }

    
    void Update ( ) {
        m_Renderer.sharedMaterial.SetTexture(REF_TEX_PROPERTY_NAME, refTex);
    }

    // 在渲染物体之前回调
    void OnWillRenderObject ( ) {
        if (busy) return;
        busy = true;
        //
        //prepare mirror camera
        //if you worked in editor,you would better choose Camera.main,else Camera.current is the camera worked for editor view port
        Camera cam = m_mainCamera;
        mirCam.CopyFrom(cam);

        // 设置镜子相机为镜子的子物体，把两个相机转换到镜子物体的空间
        m_mirCamTransform.parent = m_Transform;

        m_mainCameraTransform.parent = m_Transform;
        Vector3 mPos = m_mirCamTransform.localPosition;

        // 对镜子法线方向的坐标取负，对位置做镜像
        mPos.y *= -1f;
        m_mirCamTransform.localPosition = mPos;      // into mirror

        // 把角度也镜像了
        Vector3 rt = m_mainCameraTransform.localEulerAngles;
        m_mainCameraTransform.parent = null;

        m_v3RotationMirrored.x = -rt.x;
        m_v3RotationMirrored.y = rt.y;
        m_v3RotationMirrored.z = -rt.z;
        m_mirCamTransform.localEulerAngles = m_v3RotationMirrored;   //rotation mirrored

        float d = Vector3.Dot(m_Transform.up, m_mainCameraTransform.position - m_Transform.position) + 0.05f;
        mirCam.nearClipPlane = d;
        // 反射哪几层
        mirCam.cullingMask = ~(1 << 4) & m_ReflectLayers.value; // never render water layer

        // find out the reflection plane: position and normal in world space
        Vector3 pos = m_Transform.position;
        Vector3 normal = m_Transform.up;
        Vector4 clipPlane = CameraSpacePlane(mirCam, pos, normal, 1.0f);
        Matrix4x4 proj = cam.projectionMatrix;
        CalculateObliqueMatrix(ref proj, clipPlane);
        mirCam.projectionMatrix = proj;// you can 注释和反注释这行代码 ，然后观察小球体是否会被反射

        mirCam.targetTexture = refTex;
        mirCam.Render( );//render from mirror


        Proj( );//set proj matrix
        m_Renderer.sharedMaterial.SetMatrix(PROJ_MAT_PROPERTY_NAME, cm);

        busy = false;
        //Debug.Break();
    }

    #region Init
    
    void initComponent ( ) {
        m_Transform = GetComponent<Transform>( );
        m_Renderer = GetComponent<Renderer>( );
        m_mainCamera = Camera.main;
        m_mainCameraTransform = m_mainCamera.GetComponent<Transform>( );
        m_mirCamTransform = mirCam.GetComponent<Transform>( );
    }

    void initMirrorCamera ( ) {
        GameObject g = new GameObject("Mirror Camera");
        // 不在层级视图里显示
        g.hideFlags = HideFlags.HideAndDontSave;
        mirCam = g.AddComponent<Camera>( );
        mirCam.enabled = false;
    }

    void initRenderTexture ( ) {
        refTex = new RenderTexture(m_renderSize, m_renderSize, 16);
       
        refTex.hideFlags = HideFlags.DontSave;
        mirCam.targetTexture = refTex;
        m_Renderer.sharedMaterial.SetTexture(REF_TEX_PROPERTY_NAME, refTex);
    }

    void initCorrectionMatrix ( ) {
        correction = Matrix4x4.identity;
        correction.SetColumn(3, new Vector4(0.5f, 0.5f, 0.5f, 1f));
        correction.m00 = 0.5f;
        correction.m11 = 0.5f;
        correction.m22 = 0.5f;
    }

    void initValue ( ) {
        busy = false;

        m_v3RotationMirrored = Vector3.zero;
        m_v4ClipPlane = m_v4CameraSpacePlane = Vector4.zero;       
    }

    #endregion Init

    void Proj ( ) {
        world2ProjView = m_mirCamTransform.worldToLocalMatrix;   //
        projM = mirCam.projectionMatrix;
        projM.m32 = 1f;
        cm = correction * projM * world2ProjView;
    }

    //Given position/normal of the plane, calculates plane in camera space.
    private Vector4 CameraSpacePlane (Camera cam, Vector3 pos, Vector3 normal, float sideSign) {
        Vector3 offsetPos = pos + normal * 0.05f;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cpos = m.MultiplyPoint(offsetPos);
        Vector3 cnormal = m.MultiplyVector(normal).normalized * sideSign;

        m_v4CameraSpacePlane.x = cnormal.x;
        m_v4CameraSpacePlane.y = cnormal.y;
        m_v4CameraSpacePlane.z = cnormal.z;
        m_v4CameraSpacePlane.w = -Vector3.Dot(cpos, cnormal);

        return m_v4CameraSpacePlane;
    }

    //Adjusts the given projection matrix so that near plane is the given clipPlane
    //clipPlane is given in camera space. See article in Game Programming Gems 5 and
    //http://aras-p.info/texts/obliqueortho.html
    private void CalculateObliqueMatrix (ref Matrix4x4 projection, Vector4 clipPlane) {
        m_v4ClipPlane.x = sgn(clipPlane.x);
        m_v4ClipPlane.y = sgn(clipPlane.y);
        m_v4ClipPlane.w = m_v4ClipPlane.z = 1F;

        Vector4 q = projection.inverse * m_v4ClipPlane;
        Vector4 c = clipPlane * (2.0F / (Vector4.Dot(clipPlane, q)));
        // third row = clip plane - fourth row
        projection[2] = c.x - projection[3];
        projection[6] = c.y - projection[7];
        projection[10] = c.z - projection[11];
        projection[14] = c.w - projection[15];
    }

    //Extended sign: returns -1, 0 or 1 based on sign of a
    private float sgn (float a) {
        if (a > 0.0f) return 1.0f;
        if (a < 0.0f) return -1.0f;
        return 0.0f;
    }
}