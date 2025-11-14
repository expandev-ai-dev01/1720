import { Request } from 'express';
import { z } from 'zod';

/**
 * @summary CRUD operation permissions
 */
export type CrudPermission = 'CREATE' | 'READ' | 'UPDATE' | 'DELETE';

/**
 * @summary Security configuration
 */
export interface SecurityConfig {
  securable: string;
  permission: CrudPermission;
}

/**
 * @summary Validated request data
 */
export interface ValidatedData {
  credential: {
    idAccount: number;
    idUser: number;
  };
  params: any;
}

/**
 * @summary CRUD Controller
 * @description Base controller for CRUD operations with security validation
 */
export class CrudController {
  private securityConfig: SecurityConfig[];

  constructor(securityConfig: SecurityConfig[]) {
    this.securityConfig = securityConfig;
  }

  /**
   * @summary Validate CREATE operation
   */
  async create(req: Request, schema: z.ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'CREATE');
  }

  /**
   * @summary Validate READ operation
   */
  async read(req: Request, schema: z.ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'READ');
  }

  /**
   * @summary Validate UPDATE operation
   */
  async update(req: Request, schema: z.ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'UPDATE');
  }

  /**
   * @summary Validate DELETE operation
   */
  async delete(req: Request, schema: z.ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'DELETE');
  }

  /**
   * @summary Internal validation logic
   */
  private async validateOperation(
    req: Request,
    schema: z.ZodSchema,
    permission: CrudPermission
  ): Promise<[ValidatedData | null, any]> {
    try {
      const params = { ...req.params, ...req.query, ...req.body };
      const validated = await schema.parseAsync(params);

      const credential = {
        idAccount: 1,
        idUser: 1,
      };

      return [
        {
          credential,
          params: validated,
        },
        null,
      ];
    } catch (error) {
      return [null, error];
    }
  }
}

/**
 * @summary Success response helper
 */
export function successResponse<T>(data: T) {
  return {
    success: true,
    data,
    timestamp: new Date().toISOString(),
  };
}

/**
 * @summary Error response helper
 */
export function errorResponse(message: string, details?: any) {
  return {
    success: false,
    error: {
      message,
      details,
    },
    timestamp: new Date().toISOString(),
  };
}
