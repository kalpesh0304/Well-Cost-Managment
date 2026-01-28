// Security and Audit Entities
namespace wcm.security;

using { wcm.common as common } from './common';
using { cuid, managed } from '@sap/cds/common';

// ============================================
// AUDIT LOGS
// ============================================
entity AuditLogs : cuid {
  key ID                : UUID;
  eventCategory         : String(50) not null;   // Authentication, Authorization, DataChange, etc.
  eventType             : String(100) not null;
  entityType            : String(50);
  entityId              : UUID;
  userId                : String(100) not null;
  userName              : String(100);
  action                : String(20) not null;   // Create, Read, Update, Delete, Approve, Reject
  beforeValue           : LargeString;           // JSON snapshot
  afterValue            : LargeString;           // JSON snapshot
  timestamp             : Timestamp not null;
  ipAddress             : String(45);
  sessionId             : UUID;
  correlationId         : UUID;
  userAgent             : String(500);
}

// ============================================
// USERS
// ============================================
entity Users : common.MasterData {
  key ID                : UUID;
  userId                : String(100) not null @mandatory;
  userName              : String(100) not null;
  email                 : String(100) not null;
  department            : String(50);
  title                 : String(50);
  manager               : Association to Users;
  status                : String(20) not null default 'Active'; // Active, Inactive, Suspended
  lastLoginAt           : Timestamp;

  // Role assignments
  roles                 : Composition of many UserRoles on roles.user = $self;

  // Preferences
  preferences           : Composition of many UserPreferences on preferences.user = $self;
}

// ============================================
// ROLES
// ============================================
entity Roles : common.MasterData {
  key ID                : UUID;
  roleCode              : String(50) not null @mandatory;
  roleName              : String(100) not null;
  roleType              : String(20);            // Application, Business, Admin
  description           : String(500);

  // Scope definitions
  scopes                : Composition of many RoleScopes on scopes.role = $self;
}

entity RoleScopes : cuid {
  role                  : Association to Roles not null;
  scopeCode             : String(50) not null;   // WellRead, AFEWrite, etc.
  scopeName             : String(100);
  scopeType             : String(20);            // Read, Write, Approve, Admin
}

// ============================================
// USER ROLES
// ============================================
entity UserRoles : cuid, managed {
  user                  : Association to Users not null;
  role                  : Association to Roles not null;
  scopeType             : String(20);            // Global, Field, Well
  scopeValue            : String(50);            // Field code or well number
  effectiveFromDate     : Date not null;
  effectiveToDate       : Date;
  assignedBy            : String(100);
  assignedAt            : Timestamp;
}

// ============================================
// USER PREFERENCES
// ============================================
entity UserPreferences : cuid {
  user                  : Association to Users not null;
  preferenceKey         : String(100) not null;
  preferenceValue       : String(1000);
  modifiedAt            : Timestamp;
}

// ============================================
// SESSIONS
// ============================================
entity Sessions : cuid {
  key ID                : UUID;
  user                  : Association to Users not null;
  sessionToken          : String(500) not null;
  createdAt             : Timestamp not null;
  expiresAt             : Timestamp not null;
  lastActivityAt        : Timestamp;
  ipAddress             : String(45);
  userAgent             : String(500);
  isActive              : Boolean default true;
}

// ============================================
// LOGIN HISTORY
// ============================================
entity LoginHistory : cuid {
  key ID                : UUID;
  user                  : Association to Users;
  userId                : String(100) not null;
  loginAt               : Timestamp not null;
  logoutAt              : Timestamp;
  ipAddress             : String(45);
  userAgent             : String(500);
  loginStatus           : String(20);            // Success, Failed
  failureReason         : String(200);
}
