#version 450 core            // minimal GL version support expected from the GPU

struct LightSource {
  vec3 position;
  vec3 color;
  float intensity;
  int isActive;
};



int numberOfLights = 3;
uniform LightSource lightSources[3];
// TODO: shadow maps

uniform mat4 lightDepthMVP[3];   // we will get from the CPU side
uniform sampler2D shadowMaps[3]; // shadow map textures

struct Material {
    vec3 albedo;
    sampler2D albedoTexture;
    int hasTexture;
};


uniform Material material;

uniform vec3 camPos;

in vec3 fPositionModel;
in vec3 fPosition;
in vec3 fNormal;
in vec2 fTexCoord;

out vec4 colorOut; // shader output: the color response attached to this fragment

float pi = 3.1415927;

// TODO: shadows
void main() {
  vec3 n = normalize(fNormal);

  vec3 albedo;
  if  (material.hasTexture == 1)
 {
  albedo=texture(material.albedoTexture, fTexCoord).rgb;
 }
 else
{
  albedo=material.albedo;
}  



  vec3 wo = normalize(camPos - fPosition); // unit vector pointing to the camera

  vec3 radiance = vec3(0.0);
    float bias = 0.001; // small offset to reduce shadow acne (tweak as needed)

    for (int i = 0; i < numberOfLights; i++) {
        // Existing lighting code
        LightSource a_light = lightSources[i];
        if(a_light.isActive == 1) {
            vec3 wi = normalize(a_light.position - fPosition);
            float ndotl = max(dot(n, wi), 0.0);
            vec3 Li = a_light.color * a_light.intensity;

            // ------------------------------------------------------------
            // 1) Transform the fragment's world position into the light's clip space
            vec4 lightClip = lightDepthMVP[i] * vec4(fPosition, 1.0);
            // do perspective divide
            lightClip.xyz /= lightClip.w;

            // 2) Map the clip coordinates from [-1,1] to [0,1]
            vec3 shadowUV = 0.5 * lightClip.xyz + vec3(0.5);

            // 3) Initialize shadow factor
            float shadow = 0.0; // 0.0 means "not shadowed"

            // 4) Check if the fragment is within [0,1]^3
            if (shadowUV.x >= 0.0 && shadowUV.x <= 1.0 &&
                shadowUV.y >= 0.0 && shadowUV.y <= 1.0 &&
                shadowUV.z >= 0.0 && shadowUV.z <= 1.0) {

                // 5) Compare depth
                float depthFromMap = texture(shadowMaps[i], shadowUV.xy).r;
                float currentDepth = shadowUV.z - bias;
                if (currentDepth > depthFromMap) {
                    // behind something from light’s perspective => shadow
                    shadow = 1.0;
                }
            }

            // 6) Accumulate direct lighting
            // If shadow=1 => no direct contribution
            // If shadow=0 => full contribution
            radiance += (1.0 - shadow) * Li * albedo * ndotl;
        }
    }

    colorOut = vec4(radiance, 1.0);
}