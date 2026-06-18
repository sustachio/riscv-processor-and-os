#define LEDR   ((volatile unsigned int*)0x30000000)
#define VGA    ((volatile unsigned int*)0x30000004)

/*
void main(void) {
    *LEDR = 0b101010101;

    for (int x=0; x<40; x++) {
      for (int y=0; y<30; y++) {
        if ((x + y) & 1)
          *VGA = (x << 16) | (y << 8) | (0b11111111);
        else
          *VGA = (x << 16) | (y << 8) | 0;
      }
    }

    while (1);
}
*/

struct vec3 {
  float x;
  float y;
  float z;
};

// babylonian method from geeksforgeeks
float mysqrt(float n) {
  float x = n;
  float y = 1;
  float e = 0.01;
  while (((x-y < 0) ? y-x : x-y) > e) { // abs(x-y) < e
    x = (x + y) / 2;
    y = n / x;
  }
  return x;
}

struct vec3 normalize(struct vec3 in) {
  float rsqrt = 1/mysqrt(in.x * in.x + in.y * in.y + in.z * in.z);
  struct vec3 result = {
    in.x * rsqrt,
    in.y * rsqrt,
    in.z * rsqrt
  };
  return result;
}

#define MAX_MARCH_DIST 1000
#define MAX_MARCH_STEPS 100
#define MARCH_NEAR_DIST 0.1

float distance_to_scene(struct vec3 point) {
  // size 1 sphere at z=5
  /*
  return __builtin_sqrtf(point.x * point.x +
                         point.y * point.y +
                         (point.z - 5.0f) * (point.z - 5.0f))
                      - 1; // size
  */
  float sphere1 = mysqrt((point.x + 2.0f) * (point.x + 2.0f) +
                       (point.y - 1.0f) * (point.y - 1.0f) +
                       (point.z - 5.0f) * (point.z - 5.0f))
                  - 1.0f; // size
  float sphere2 = mysqrt((point.x - 1.0f) * (point.x - 1.0f) +
                       (point.y + 1.0f) * (point.y + 1.0f) +
                       (point.z - 7.0f) * (point.z - 7.0f))
                  - 3.0f; // size

  return (sphere1 < sphere2) ? sphere1 : sphere2;
}

// returns distance
float ray_march(struct vec3 ray_direction) {
  float march_distance = 0;
  float d;
  for (int march_step = 0; 
        march_distance < MAX_MARCH_DIST &&
        march_step < MAX_MARCH_STEPS;
        march_step++) {
    struct vec3 point = {ray_direction.x * march_distance, 
                          ray_direction.y * march_distance,
                          ray_direction.z * march_distance};

    d = distance_to_scene(point);
    march_distance += d;

    if (d <= MARCH_NEAR_DIST)
      return march_distance;
  }
  return march_distance;
}

int main() {
    int width = 40;
    int height = 30;

    *LEDR = 0b101010101;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        *LEDR = y * width + x;

        float uv_x = (float)(x - width/2) / (float)height;
        float uv_y = (float)(y - height/2) / (float)height;

        struct vec3 ray_direction = {uv_x, uv_y, (float)1};
        ray_direction = normalize(ray_direction);

        // write result
        float d = ray_march(ray_direction);
        float color = (d <= MAX_MARCH_DIST) ? d : 0;
        color = (7.0f - color) * (255 / 4);

        *VGA = (x << 16) | (y << 8) | (0b11111111 & (int)color); // weird!
      }
  }

  return 0;
}