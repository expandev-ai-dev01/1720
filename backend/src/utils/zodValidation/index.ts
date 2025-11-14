import { z } from 'zod';

/**
 * @summary Common Zod validation schemas
 * @description Reusable validation schemas for consistent data validation
 */

/**
 * @summary String validation
 */
export const zString = z.string().min(1);

/**
 * @summary Nullable string validation
 */
export const zNullableString = (maxLength?: number) => {
  let schema = z.string();
  if (maxLength) {
    schema = schema.max(maxLength);
  }
  return schema.nullable();
};

/**
 * @summary Name validation (1-200 characters)
 */
export const zName = z.string().min(1).max(200);

/**
 * @summary Description validation (max 500 characters)
 */
export const zDescription = z.string().max(500);

/**
 * @summary Nullable description validation
 */
export const zNullableDescription = z.string().max(500).nullable();

/**
 * @summary Foreign key validation
 */
export const zFK = z.coerce.number().int().positive();

/**
 * @summary Nullable foreign key validation
 */
export const zNullableFK = z.coerce.number().int().positive().nullable();

/**
 * @summary Bit/Boolean validation
 */
export const zBit = z.coerce.number().int().min(0).max(1);

/**
 * @summary Date string validation
 */
export const zDateString = z.string().datetime();

/**
 * @summary Nullable date string validation
 */
export const zNullableDateString = z.string().datetime().nullable();

/**
 * @summary Email validation
 */
export const zEmail = z.string().email().max(255);

/**
 * @summary Numeric validation (15,2)
 */
export const zNumeric = z.coerce.number();

/**
 * @summary Price validation (18,6)
 */
export const zPrice = z.coerce.number().nonnegative();

/**
 * @summary Nullable price validation
 */
export const zNullablePrice = z.coerce.number().nonnegative().nullable();
