import { getPool } from '@/utils/database';

/**
 * @summary Database instance
 * @description Singleton database connection pool instance
 */
export const databaseInstance = {
  getConnection: getPool,
};
