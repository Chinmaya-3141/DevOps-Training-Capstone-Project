import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

// Mock axios to prevent network calls during tests
jest.mock('axios');

test('renders DevOps Capstone Project heading', () => {
  render(<App />);
  const headingElement = screen.getByText(/DevOps Capstone Project/i);
  expect(headingElement).toBeInTheDocument();
});

test('renders microservices demo description', () => {
  render(<App />);
  const descriptionElement = screen.getByText(/Microservices Demo Application/i);
  expect(descriptionElement).toBeInTheDocument();
});

test('renders add item form', () => {
  render(<App />);
  const addItemHeading = screen.getByText(/Add New Item/i);
  expect(addItemHeading).toBeInTheDocument();
});

test('renders health check button', () => {
  render(<App />);
  const healthButton = screen.getByText(/Check Backend Health/i);
  expect(healthButton).toBeInTheDocument();
});