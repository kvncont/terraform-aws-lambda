export const handler = async (event) => {
    // TODO implement
    const response = {
      statusCode: 200,
      body: "Hello from Lambda!",
      event: event
    };
    return response;
  };