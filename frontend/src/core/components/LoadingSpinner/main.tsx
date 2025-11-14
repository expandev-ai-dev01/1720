import { getLoadingSpinnerClassName } from './variants';
import type { LoadingSpinnerProps } from './types';

export const LoadingSpinner = ({ size = 'md', className }: LoadingSpinnerProps) => {
  return (
    <div className="flex items-center justify-center p-8">
      <div className={getLoadingSpinnerClassName({ size, className })} />
    </div>
  );
};
