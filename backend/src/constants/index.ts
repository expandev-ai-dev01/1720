/**
 * @summary Application constants
 * @description Centralized constants for the LoveCakes backend
 */

/**
 * @summary HTTP status codes
 */
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  INTERNAL_SERVER_ERROR: 500,
};

/**
 * @summary Error messages
 */
export const ERROR_MESSAGES = {
  INTERNAL_SERVER_ERROR: 'internalServerError',
  VALIDATION_ERROR: 'validationError',
  NOT_FOUND: 'notFound',
  UNAUTHORIZED: 'unauthorized',
  FORBIDDEN: 'forbidden',
};
