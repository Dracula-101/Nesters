"use client";

import Button from "@/app/components/Button/Button";

const intents = [
  "primary",
  "secondary",
  "danger",
  "success",
  "warning",
  "info",
  "light",
  "dark",
  "ghost",
  "link",
];

const sizes = ["sm", "md", "lg", "xl"];

const btnTypes = ["button", "icon"]; // only 2 types
export default function Home() {
  return (
    <div className="p-10 grid grid-cols-1 md:grid-cols-2 gap-8">
      {btnTypes.map((btnType) => (
        <div key={btnType}>
          <h2 className="text-2xl font-bold mb-4 capitalize">
            {btnType} Buttons
          </h2>
          <div className="flex flex-col gap-6">
            {intents.map((intent) => (
              <div key={intent}>
                <h3 className="text-lg font-semibold capitalize mb-2">
                  {intent}
                </h3>
                <div className="flex flex-wrap gap-4 items-center">
                  {sizes.map((size) => (
                    <Button
                      key={`${btnType}-${intent}-${size}`}
                      intent={intent}
                      size={size}
                      btnType={btnType}
                      // className="mb-2"
                    >
                      {btnType === "icon" ? "+" : `${intent} ${size}`}
                    </Button>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
