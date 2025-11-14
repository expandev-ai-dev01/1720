import sql from 'mssql';
import { config } from '@/config';

/**
 * @summary Expected return types for database operations
 */
export enum ExpectedReturn {
  Single = 'Single',
  Multi = 'Multi',
  None = 'None',
}

/**
 * @summary Record set interface
 */
export interface IRecordSet<T = any> {
  recordset: T[];
  rowsAffected: number[];
}

/**
 * @summary Database connection pool
 */
let pool: sql.ConnectionPool | null = null;

/**
 * @summary Get database connection pool
 */
export async function getPool(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await sql.connect(config.database);
  }
  return pool;
}

/**
 * @summary Execute database request
 * @description Executes stored procedures with proper parameter handling
 *
 * @param routine Stored procedure name
 * @param parameters Input parameters object
 * @param expectedReturn Expected return type
 * @param transaction Optional transaction object
 * @param resultSetNames Optional names for result sets
 */
export async function dbRequest(
  routine: string,
  parameters: any = {},
  expectedReturn: ExpectedReturn = ExpectedReturn.Single,
  transaction?: sql.Transaction,
  resultSetNames?: string[]
): Promise<any> {
  try {
    const currentPool = await getPool();
    const request = transaction ? new sql.Request(transaction) : new sql.Request(currentPool);

    Object.keys(parameters).forEach((key) => {
      request.input(key, parameters[key]);
    });

    const result = await request.execute(routine);

    if (expectedReturn === ExpectedReturn.None) {
      return null;
    }

    if (expectedReturn === ExpectedReturn.Single) {
      return result.recordset[0];
    }

    if (expectedReturn === ExpectedReturn.Multi) {
      if (resultSetNames && resultSetNames.length > 0) {
        const namedResults: any = {};
        resultSetNames.forEach((name, index) => {
          namedResults[name] = result.recordsets[index];
        });
        return namedResults;
      }
      return result.recordsets;
    }

    return result.recordset;
  } catch (error: any) {
    console.error('Database request error:', {
      routine,
      error: error.message,
      stack: error.stack,
    });
    throw error;
  }
}

/**
 * @summary Begin transaction
 */
export async function beginTransaction(): Promise<sql.Transaction> {
  const currentPool = await getPool();
  const transaction = new sql.Transaction(currentPool);
  await transaction.begin();
  return transaction;
}

/**
 * @summary Commit transaction
 */
export async function commitTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.commit();
}

/**
 * @summary Rollback transaction
 */
export async function rollbackTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.rollback();
}
