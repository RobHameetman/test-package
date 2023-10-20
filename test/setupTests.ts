/**
 * `jest-dom` adds custom Jest matchers for asserting on DOM nodes.
 * This allows you to do things like:
 *
 * ```
 * expect(element).toHaveTextContent(/hello/i);
 * ```
 *
 * @see https://github.com/testing-library/jest-dom
 */
import { configure } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import 'jest-location-mock';

configure({
	testIdAttribute: 'data-test-id',
});
