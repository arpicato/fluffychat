enum MatrixPowerLevelRole { user, moderator, admin, owner }

const int kMatrixModeratorPowerLevel = 50;
const int kMatrixAdminPowerLevel = 100;
const int kMatrixOwnerPowerLevel = 9007199254740991;

MatrixPowerLevelRole matrixPowerLevelRoleFor(dynamic powerLevel) {
  final int level;
  if (powerLevel is int) {
    level = powerLevel;
  } else {
    level = (powerLevel as dynamic).level as int;
  }
  if (level >= kMatrixOwnerPowerLevel) {
    return MatrixPowerLevelRole.owner;
  }
  if (level >= kMatrixAdminPowerLevel) {
    return MatrixPowerLevelRole.admin;
  }
  if (level >= kMatrixModeratorPowerLevel) {
    return MatrixPowerLevelRole.moderator;
  }
  return MatrixPowerLevelRole.user;
}

bool isAdminLikePowerLevel(dynamic powerLevel) {
  if (powerLevel is int) {
    return powerLevel >= kMatrixAdminPowerLevel;
  }
  return ((powerLevel as dynamic).level as int) >= kMatrixAdminPowerLevel;
}
