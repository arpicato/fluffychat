enum MatrixPowerLevelRole {
  user,
  moderator,
  admin,
  owner,
}

const int kMatrixModeratorPowerLevel = 50;
const int kMatrixAdminPowerLevel = 100;
const int kMatrixOwnerPowerLevel = 9007199254740991;

MatrixPowerLevelRole matrixPowerLevelRoleFor(int powerLevel) {
  if (powerLevel >= kMatrixOwnerPowerLevel) {
    return MatrixPowerLevelRole.owner;
  }
  if (powerLevel >= kMatrixAdminPowerLevel) {
    return MatrixPowerLevelRole.admin;
  }
  if (powerLevel >= kMatrixModeratorPowerLevel) {
    return MatrixPowerLevelRole.moderator;
  }
  return MatrixPowerLevelRole.user;
}

bool isAdminLikePowerLevel(int powerLevel) =>
    powerLevel >= kMatrixAdminPowerLevel;
