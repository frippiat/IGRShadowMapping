#version 450 core            // minimal GL version support expected from the GPU

struct LightSource {
  vec3 position;
  vec3 color;
  float intensity;
  int isActive;
};



int numberOfLights = 3;
uniform LightSource lightSources[3];

uniform mat4 lightDepthMVP[3];   
uniform sampler2D shadowMaps[3]; 

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

out vec4 colorOut; 

float pi = 3.1415927;

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



  vec3 wo = normalize(camPos - fPosition); 

  vec3 radiance = vec3(0.0);
    for (int i = 0; i < numberOfLights; i++) {
        LightSource a_light = lightSources[i];
        if(a_light.isActive == 1) {
            vec3 wi = normalize(a_light.position - fPosition);
            float ndotl = max(dot(n, wi), 0.0);
            vec3 Li = a_light.color * a_light.intensity;

            vec4 lightClip = lightDepthMVP[i] * vec4(fPosition, 1.0);
            lightClip.xyz /= lightClip.w;

            vec3 shadowUV = 0.5 * lightClip.xyz + vec3(0.5);

            float shadow = 0.0; // 0.0 means "not shadowed"

            float depthFromMap = texture(shadowMaps[i], shadowUV.xy).r;
            float currentDepth = shadowUV.z - 0.001;
            if (currentDepth > depthFromMap) 
            {
                shadow = 1.0;
            }

            // If shadow=1 => no contribution
            // If shadow=0 => full contribution
            radiance += (1.0 - shadow) * Li * albedo * ndotl;
        }
    }

    colorOut = vec4(radiance, 1.0);
}