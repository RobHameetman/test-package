import { main } from './main';

describe('main()', () => {
	let error: Error | null = null;

	beforeAll(() => {
		jest.spyOn(console, 'log').mockImplementation(jest.fn());
	});

	beforeEach(() => {
		try {
			main();
		} catch (thrown) {
			error = !(thrown instanceof Error) ? (thrown as Error) : new Error();
			console.error(thrown);
		}
	});

	afterEach(() => {
		error = null;
	});

	afterAll(() => {
		jest.restoreAllMocks();
	});

	it('should not throw an error', () => {
		expect(error).toBeNull();
	});

	it('should log "Hello, World!" to the console', () => {
		expect(console.log).toBeCalledWith('Hello World!');
	});
});
