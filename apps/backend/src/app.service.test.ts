import { beforeEach, describe, expect, it } from 'vitest'
import { AppService } from './app.service'

describe('appService', () => {
  let appService: AppService

  beforeEach(() => {
    appService = new AppService()
  })

  it('should return "Hello World!"', () => {
    expect(appService.getHello()).toBe('Hello World!')
  })
})
