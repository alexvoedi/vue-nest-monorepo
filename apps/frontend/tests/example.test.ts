import { describe } from 'vitest'

describe('example', (it) => {
  it('should return "Hello World!"', ({ expect }) => {
    expect('Hello World!').toEqual('Hello World!')
  })
})
