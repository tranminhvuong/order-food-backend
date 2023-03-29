import { HttpException, ValidationPipe } from '@nestjs/common';
import { ValidationError } from 'class-validator';

export const GlobalValidationPipe = new ValidationPipe({
  whitelist: true,
  exceptionFactory: (errors: ValidationError[]) => {
    const errorMessages = {};
    errors.forEach((error: ValidationError) => {
      errorMessages[error.property] = Object.values(error.constraints);
    });
    return new HttpException(
      {
        errors: errorMessages,
        statusCode: 422,
        message: 'Validation errors',
      },
      422,
    );
  },
});
