/// Task 1633: 3D particle emitter simulating airflow, aspiration, and nasal venting
class AirflowParticleEmitter {
  int getParticleCount(bool isAspirated, bool isNasal) => isAspirated ? 150 : (isNasal ? 80 : 40);
}
